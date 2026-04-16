# Modernized Architecture — PawsCare on Azure Container Apps

This document describes the target architecture after migrating the PawsCare Veterinary Network from three on-premises VMs to Azure Container Apps with Dapr, KEDA, and managed Azure services.

---

## Container Apps Topology

```
                            ┌─────────────────────────┐
                            │      Azure Front Door    │
                            │    (TLS termination)     │
                            └────────────┬────────────┘
                                         │ HTTPS
                                         ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                   AZURE CONTAINER APPS ENVIRONMENT                          │
│                   (Managed Kubernetes + Envoy ingress)                      │
│                                                                              │
│  ┌────────────────────────┐   ┌────────────────────────┐                    │
│  │  web-frontend           │   │  api-server             │                    │
│  │  ASP.NET Core 8         │   │  Node.js 18 + Express   │                    │
│  │  Port: 8080             │   │  Port: 3000              │                    │
│  │  External ingress: true │   │  Internal ingress: true  │                    │
│  │                         │   │                          │                    │
│  │  ┌───────────────────┐  │   │  ┌───────────────────┐   │                    │
│  │  │ Dapr Sidecar      │  │   │  │ Dapr Sidecar      │   │                    │
│  │  │ App ID:           │  │   │  │ App ID:           │   │                    │
│  │  │  web-frontend     │──┼───┼──│  api-server       │   │                    │
│  │  │ HTTP port: 3500   │  │   │  │ HTTP port: 3500   │   │                    │
│  │  └───────────────────┘  │   │  └───────────────────┘   │                    │
│  │                         │   │                          │                    │
│  │  Scale: 1–10 replicas   │   │  Scale: 2–20 replicas    │                    │
│  │  Trigger: HTTP (10 req) │   │  Trigger: HTTP (20 req)  │                    │
│  └────────────────────────┘   └────────────────────────┘                    │
│                                                                              │
│  ┌────────────────────────┐                                                  │
│  │  background-worker      │                                                  │
│  │  Python 3.11 + Flask    │                                                  │
│  │  Port: 8080             │                                                  │
│  │  Internal (no ingress)  │                                                  │
│  │                         │                                                  │
│  │  ┌───────────────────┐  │                                                  │
│  │  │ Dapr Sidecar      │  │                                                  │
│  │  │ App ID:           │  │                                                  │
│  │  │  background-worker│  │                                                  │
│  │  │ HTTP port: 3500   │  │                                                  │
│  │  └───────────────────┘  │                                                  │
│  │                         │                                                  │
│  │  Scale: 0–5 replicas    │                                                  │
│  │  Trigger: Service Bus   │                                                  │
│  │  (5 msg queue depth)    │                                                  │
│  └────────────────────────┘                                                  │
│                                                                              │
│  ┌──────────────────────────────────────────────┐                            │
│  │               Log Analytics Workspace         │                            │
│  │               (30-day retention, PerGB2018)    │                            │
│  └──────────────────────────────────────────────┘                            │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Dapr Components

Dapr provides the building blocks that decouple application code from infrastructure.

| Component | Type | Local Dev | Production (Azure) |
|-----------|------|-----------|-------------------|
| **Pub/Sub** | `pubsub.rabbitmq` / `pubsub.azure.servicebus.topics` | RabbitMQ on `localhost:5672` | Azure Service Bus (Standard tier) |
| **State Store** | `state.mongodb` / `state.azure.cosmosdb` | MongoDB on `localhost:27017` | Azure Cosmos DB (MongoDB API) |
| **Blob Binding** | `bindings.azure.blobstorage` | — | Azure Blob Storage |

### Pub/Sub Topics

| Topic | Publisher | Subscriber | Purpose |
|-------|-----------|------------|---------|
| `appointment_reminders` | api-server | background-worker | Triggers reminder emails when appointments are booked |
| `lab_results` | api-server | background-worker | Triggers PDF generation and blob upload on lab result submission |

### Pub/Sub Configuration (Production)

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
spec:
  type: pubsub.azure.servicebus.topics
  metadata:
    - name: connectionString
      secretKeyRef: servicebus-connection
    - name: maxDeliveryCount
      value: "10"
    - name: lockDurationInSec
      value: "30"
    - name: defaultMessageTimeToLiveInSec
      value: "86400"
    - name: maxConcurrentHandlers
      value: "10"
```

### State Store Configuration (Production)

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.azure.cosmosdb
  metadata:
    - name: url
      value: <cosmos-endpoint>
    - name: masterKey
      secretKeyRef: cosmos-master-key
    - name: database
      value: pawscare-state
    - name: collection
      value: state
    - name: actorStateStore
      value: "true"
```

### Blob Storage Binding

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: blobstore
spec:
  type: bindings.azure.blobstorage
  metadata:
    - name: storageAccount
      secretKeyRef: blob-account-name
    - name: storageAccessKey
      secretKeyRef: blob-account-key
    - name: container
      value: documents
    - name: decodeBase64
      value: "true"
```

### Dapr Tracing

Zipkin tracing is enabled at sampling rate 1.0 for local development. In production, Application Insights can replace Zipkin via the Container Apps built-in telemetry.

---

## KEDA Scaling Rules

Container Apps uses KEDA to auto-scale containers based on event-driven metrics.

```
                    ┌──────────────────┐
                    │   HTTP Requests   │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
   ┌──────────────────┐         ┌──────────────────┐
   │  web-frontend     │         │  api-server       │
   │  Min: 1           │         │  Min: 2           │
   │  Max: 10          │         │  Max: 20          │
   │  Threshold: 10    │         │  Threshold: 20    │
   │  concurrent req   │         │  concurrent req   │
   └──────────────────┘         └──────────────────┘

                    ┌──────────────────┐
                    │  Service Bus     │
                    │  Queue Depth     │
                    └────────┬─────────┘
                             │
                             ▼
                  ┌──────────────────┐
                  │ background-worker │
                  │ Min: 0 (→ zero!) │
                  │ Max: 5           │
                  │ Threshold: 5 msg │
                  └──────────────────┘
```

| Service | Scaler | Min Replicas | Max Replicas | Trigger |
|---------|--------|:------------:|:------------:|---------|
| **web-frontend** | HTTP | 1 | 10 | 10 concurrent requests/instance |
| **api-server** | HTTP | 2 | 20 | 20 concurrent requests/instance |
| **background-worker** | Azure Service Bus | 0 | 5 | 5 messages in queue |

**Key behaviors:**
- The background worker **scales to zero** when no messages are pending, eliminating idle cost.
- KEDA polls scaling metrics every **30 seconds**.
- A **5-minute stabilization window** prevents scaling flap.
- The API server maintains a minimum of **2 replicas** for high availability.

---

## Azure Service Dependencies

```
┌─────────────────────────────────────────────────────────────────────┐
│                         RESOURCE GROUP                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────┐   ┌─────────────────────┐                  │
│  │ Azure Container      │   │ Azure Container     │                  │
│  │ Registry (ACR)       │   │ Apps Environment    │                  │
│  │ Basic SKU            │   │ Dapr-enabled        │                  │
│  └─────────────────────┘   └─────────────────────┘                  │
│                                                                     │
│  ┌─────────────────────┐   ┌─────────────────────┐                  │
│  │ Azure Cosmos DB      │   │ Azure Service Bus   │                  │
│  │ MongoDB API v4.2     │   │ Standard tier       │                  │
│  │ Session consistency  │   │ Topics:             │                  │
│  │ Databases:           │   │  appointment_       │                  │
│  │  - pawscare          │   │    reminders        │                  │
│  │  - pawscare-state    │   │  lab_results        │                  │
│  └─────────────────────┘   └─────────────────────┘                  │
│                                                                     │
│  ┌─────────────────────┐   ┌─────────────────────┐                  │
│  │ Azure Blob Storage   │   │ Azure SQL Database  │                  │
│  │ StorageV2, Std LRS   │   │ Standard S0 tier    │                  │
│  │ Containers:          │   │ 2 GB max size       │                  │
│  │  - documents         │   │ Allow Azure svcs    │                  │
│  │  - lab-results       │   │                     │                  │
│  │  - reports           │   │                     │                  │
│  │  - xrays             │   │                     │                  │
│  └─────────────────────┘   └─────────────────────┘                  │
│                                                                     │
│  ┌─────────────────────┐                                            │
│  │ Log Analytics        │                                            │
│  │ Workspace            │                                            │
│  │ 30-day retention     │                                            │
│  └─────────────────────┘                                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Security & Networking

- All Azure services enforce **TLS 1.2 minimum**.
- Cosmos DB, Service Bus, SQL, and Storage have **public network access disabled** by default.
- Storage accounts use **HTTPS only** with soft delete (7 days).
- Azure SQL allows firewall bypass for Azure services (`0.0.0.0`).
- Container Apps ingress provides **automatic TLS termination**.

---

## Network Flow Diagram

```
┌──────────┐       HTTPS        ┌──────────────────────────────────────────┐
│  Browser  │ ─────────────────▶ │  web-frontend (external ingress :8080)   │
└──────────┘                    └──────────┬───────────────────────────────┘
                                           │
                                           │ Dapr Service Invocation
                                           │ http://localhost:3500/v1.0/invoke/api-server/method/*
                                           ▼
                                ┌──────────────────────────────────────────┐
                                │  api-server (internal ingress :3000)      │
                                │                                           │
                                │  ┌─ MongoDB queries ──▶ Cosmos DB        │
                                │  │                                        │
                                │  ├─ POST /api/appointments                │
                                │  │   └─ Dapr Pub/Sub ──▶ Service Bus     │
                                │  │       topic: appointment_reminders     │
                                │  │                                        │
                                │  └─ POST /api/labresults                  │
                                │      └─ Dapr Pub/Sub ──▶ Service Bus     │
                                │          topic: lab_results               │
                                └──────────────────────────────────────────┘
                                                     │
                              Service Bus Topics      │
                              (subscription delivery) │
                                                     ▼
                                ┌──────────────────────────────────────────┐
                                │  background-worker (no ingress :8080)     │
                                │                                           │
                                │  POST /events/appointment_reminders       │
                                │    └─ Send reminder email (SMTP)          │
                                │                                           │
                                │  POST /events/lab_results                 │
                                │    ├─ Generate PDF report (reportlab)      │
                                │    └─ Dapr Blob Binding ──▶ Blob Storage │
                                │        container: documents/lab-results   │
                                └──────────────────────────────────────────┘

                                ┌──────────────────────────────────────────┐
                                │  web-frontend also queries:               │
                                │    └─ Azure SQL Database (EF Core)        │
                                │       via connection string               │
                                └──────────────────────────────────────────┘
```

### Request Flow Summary

1. **User** → Browser → HTTPS → **web-frontend** (ASP.NET Core)
2. **web-frontend** → Dapr sidecar → service invocation → **api-server** (Node.js)
3. **api-server** → Mongoose → **Cosmos DB** (MongoDB API) for CRUD
4. **api-server** → Dapr sidecar → pub/sub → **Service Bus** topic
5. **Service Bus** → subscription → Dapr sidecar → **background-worker** (Python)
6. **background-worker** → generates PDF → Dapr blob binding → **Blob Storage**
7. **web-frontend** → Entity Framework Core → **Azure SQL** for frontend data

---

## Infrastructure as Code

All resources are defined in Bicep templates under `infrastructure/`:

| File | Purpose |
|------|---------|
| `main.bicep` | Base infra: Log Analytics, ACR, Container Apps Environment |
| `deploy.bicep` | Container App definitions with Dapr, scaling, and env vars |
| `azure-services.bicep` | Data plane: Cosmos DB, Service Bus, Blob Storage, Azure SQL |
| `modules/` | Reusable Bicep modules |

Deploy with:
```bash
az deployment group create \
    --resource-group <rg-name> \
    --template-file infrastructure/main.bicep \
    --parameters baseName=pawscare environment=prod
```
