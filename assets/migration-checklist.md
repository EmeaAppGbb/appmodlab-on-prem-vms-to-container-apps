# Migration Checklist — VMs to Azure Container Apps

Comprehensive checklist of all migration tasks completed in this lab, comparing the legacy VM-based system with the modernized container-based architecture.

---

## Service Discovery

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 1 | Service addressing | Hardcoded IPs (`10.0.1.10`, `10.0.1.20`, `10.0.1.30`) | Dapr service invocation by app ID (`api-server`, `web-frontend`) | ✅ Done |
| 2 | Frontend → API communication | Direct HTTP to `http://10.0.1.20:3000` | Dapr sidecar: `http://localhost:3500/v1.0/invoke/api-server/method/` | ✅ Done |
| 3 | DNS / load balancing | None (single VM per service) | Container Apps built-in Envoy ingress with load balancing | ✅ Done |
| 4 | Service health awareness | No health checks; manual monitoring | Dapr health endpoints + Container Apps health probes | ✅ Done |

---

## Messaging

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 5 | Message broker | Single-instance RabbitMQ on VM 3 (`10.0.1.30:5672`) | Azure Service Bus (Standard tier, managed HA) | ✅ Done |
| 6 | Pub/Sub abstraction | Direct AMQP client (`amqplib` / `pika`) with hardcoded connection | Dapr pub/sub component — code uses Dapr HTTP API only | ✅ Done |
| 7 | Topic: appointment reminders | RabbitMQ queue `appointment_reminders` | Service Bus topic `appointment_reminders` with subscription | ✅ Done |
| 8 | Topic: lab results | RabbitMQ queue `lab_results` | Service Bus topic `lab_results` with subscription | ✅ Done |
| 9 | Message durability | `persistent: true` flag on AMQP messages | Service Bus: `maxDeliveryCount=10`, `lockDuration=30s`, TTL 1 day | ✅ Done |
| 10 | Dead letter handling | None (messages lost on failure) | Service Bus built-in dead-letter queue | ✅ Done |

---

## File Storage

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 11 | Document storage | SMB file shares on local VM disk | Azure Blob Storage (StorageV2, Standard LRS) | ✅ Done |
| 12 | Lab result PDFs | Generated to local `/shared-documents/lab-results/` | Uploaded via Dapr blob binding to `documents` container | ✅ Done |
| 13 | Storage containers | Single flat directory | Four containers: `documents`, `lab-results`, `reports`, `xrays` | ✅ Done |
| 14 | Access control | OS-level file permissions | Azure RBAC + storage account keys via Dapr secrets | ✅ Done |
| 15 | Data protection | Manual backup (if any) | Blob soft delete (7 days), HTTPS-only, no public access | ✅ Done |

---

## Scaling

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 16 | Web frontend scaling | Single VM (4 vCPU, 8 GB), always on | KEDA HTTP scaler: 1–10 replicas at 10 concurrent req/instance | ✅ Done |
| 17 | API server scaling | Single VM (2 vCPU, 4 GB), always on | KEDA HTTP scaler: 2–20 replicas at 20 concurrent req/instance | ✅ Done |
| 18 | Background worker scaling | Single VM (2 vCPU, 4 GB), always on | KEDA Service Bus scaler: 0–5 replicas at 5 msg queue depth | ✅ Done |
| 19 | Scale-to-zero | Not possible — VMs always running | Background worker scales to zero when queue is empty | ✅ Done |
| 20 | Scale-up speed | Manual VM provisioning (minutes/hours) | Container instance start-up (seconds) | ✅ Done |

---

## SSL / TLS

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 21 | TLS termination | Manual certificate deployment on IIS / nginx | Container Apps automatic TLS termination | ✅ Done |
| 22 | Certificate management | Manual renewal and installation | Managed by Azure (auto-renewal) | ✅ Done |
| 23 | Internal communication | Unencrypted HTTP between VMs | Dapr mTLS for service-to-service encryption | ✅ Done |
| 24 | Minimum TLS version | Not enforced | TLS 1.2 enforced on all Azure services | ✅ Done |

---

## Health Checks

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 25 | API server health | No health endpoint | `GET /health` → JSON `{ status, mongodb, messaging }` | ✅ Done |
| 26 | Web frontend health | No health endpoint | `GET /health` → ASP.NET Core health check middleware | ✅ Done |
| 27 | Background worker health | No health endpoint | `GET /health` → Flask endpoint (Dapr mode) | ✅ Done |
| 28 | Container health probes | N/A — no containers | Dockerfile `HEALTHCHECK` + Container Apps liveness probes | ✅ Done |
| 29 | Dapr sidecar health | N/A | Dapr health API via sidecar HTTP port | ✅ Done |

---

## Deployment

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 30 | Deployment method | Manual SSH/RDP + copy files | `az deployment group create` with Bicep IaC | ✅ Done |
| 31 | Image registry | N/A — no containers | Azure Container Registry (Basic SKU) | ✅ Done |
| 32 | Container images | N/A | Multi-stage Dockerfiles for .NET, Node.js, Python | ✅ Done |
| 33 | Infrastructure as Code | VM setup shell scripts | Bicep templates (`main.bicep`, `deploy.bicep`, `azure-services.bicep`) | ✅ Done |
| 34 | Environment parity | Dev ≠ Prod (different VMs, configs) | Docker Compose locally, same containers in Container Apps | ✅ Done |
| 35 | Rollback strategy | Manual VM snapshots | Container image tags + Container Apps revision management | ✅ Done |
| 36 | Deployment script | Manual steps | `scripts/deploy-azure.ps1` / `scripts/deploy-azure.sh` | ✅ Done |

---

## Containerization

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 37 | Web frontend | IIS on Windows Server 2019 | Multi-stage Dockerfile: .NET 8 SDK → ASP.NET 8 runtime | ✅ Done |
| 38 | API server | Node.js 14 on Ubuntu VM | Multi-stage Dockerfile: Node 18-slim, non-root user (1001) | ✅ Done |
| 39 | Background worker | Python 3.8 + Celery on Ubuntu VM | Multi-stage Dockerfile: Python 3.11-slim, non-root user (1001) | ✅ Done |
| 40 | Local orchestration | 3 separate VMs | `docker-compose.yml` (legacy) + `docker-compose.dapr.yml` (Dapr overlay) | ✅ Done |
| 41 | Non-root execution | Root on all VMs | All containers run as non-root user (UID 1001) | ✅ Done |

---

## Observability

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 42 | Logging | VM syslog / Event Viewer | Log Analytics Workspace (30-day retention) | ✅ Done |
| 43 | Distributed tracing | None | Dapr + Zipkin (dev) / Application Insights (prod) | ✅ Done |
| 44 | Metrics | Manual VM monitoring | Container Apps built-in metrics + Dapr metrics | ✅ Done |

---

## Dapr Integration

| # | Task | Legacy (Before) | Modernized (After) | Status |
|---|------|-----------------|-------------------|--------|
| 45 | Service mesh | None | Dapr sidecars on all 3 services (v1.14.4) | ✅ Done |
| 46 | Pub/Sub abstraction | Direct RabbitMQ AMQP | Dapr pub/sub building block | ✅ Done |
| 47 | State management | Direct MongoDB driver | Dapr state store (Cosmos DB in production) | ✅ Done |
| 48 | Output binding | Local file system writes | Dapr blob storage binding | ✅ Done |
| 49 | Configuration | Hardcoded in application code | Dapr component YAML files (swappable per environment) | ✅ Done |
| 50 | Tracing config | None | `dapr/config.yaml` with Zipkin sampling | ✅ Done |

---

## Summary

| Category | Legacy Issues | Modernized Solution | Items |
|----------|--------------|--------------------|----- |
| Service Discovery | Hardcoded IPs, no load balancing | Dapr + Container Apps ingress | 4 |
| Messaging | Single RabbitMQ, no dead-letter | Azure Service Bus + Dapr pub/sub | 6 |
| File Storage | SMB shares, no protection | Azure Blob Storage + Dapr binding | 5 |
| Scaling | Always-on VMs, manual scaling | KEDA auto-scaling, scale-to-zero | 5 |
| SSL/TLS | Manual certificate management | Automatic TLS + mTLS | 4 |
| Health Checks | None | HTTP health endpoints + probes | 5 |
| Deployment | Manual SSH/RDP | Bicep IaC + deployment scripts | 7 |
| Containerization | Bare-metal VMs | Multi-stage Docker, non-root | 5 |
| Observability | Syslog only | Log Analytics + Zipkin + Dapr metrics | 3 |
| Dapr Integration | N/A | Full sidecar mesh | 6 |
| **Total** | | | **50** |
