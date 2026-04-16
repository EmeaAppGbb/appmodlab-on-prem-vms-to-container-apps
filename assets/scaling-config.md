# KEDA Auto-Scaling Configuration

This document describes the KEDA-based auto-scaling rules configured for each Azure Container App service in the PawsCare application.

## Overview

Azure Container Apps uses [KEDA (Kubernetes Event-Driven Autoscaling)](https://keda.sh/) to scale workloads based on event sources. Each service has scaling rules tuned to its traffic pattern and workload characteristics.

## Scaling Rules by Service

### Web Frontend (`pawscare-web-frontend`)

| Setting | Value |
|---|---|
| **Scaler Type** | HTTP |
| **Min Replicas** | 1 |
| **Max Replicas** | 10 |
| **Concurrent Requests per Instance** | 10 |

**Behavior:** The web frontend always runs at least 1 replica to avoid cold-start latency for end users. When concurrent HTTP requests exceed 10 per instance, KEDA adds replicas up to a maximum of 10. As traffic subsides, replicas scale back down to 1.

**Rationale:** As the user-facing entry point, this service must remain responsive. A low concurrency threshold (10) ensures aggressive scale-out to maintain sub-second response times under load.

---

### API Server (`pawscare-api-server`)

| Setting | Value |
|---|---|
| **Scaler Type** | HTTP |
| **Min Replicas** | 2 |
| **Max Replicas** | 20 |
| **Concurrent Requests per Instance** | 20 |

**Behavior:** The API server maintains a minimum of 2 replicas for high availability. It scales when concurrent HTTP requests exceed 20 per instance, up to 20 replicas. The higher concurrency threshold reflects that API calls are typically lighter-weight than full page renders.

**Rationale:** Keeping 2 minimum replicas ensures the API layer can handle sudden bursts without waiting for scale-up. The higher per-instance threshold (20) accounts for the API's efficient request handling.

---

### Background Worker (`pawscare-background-worker`)

| Setting | Value |
|---|---|
| **Scaler Type** | Azure Service Bus Queue (KEDA Custom) |
| **Min Replicas** | 0 |
| **Max Replicas** | 5 |
| **Queue Name** | `background-tasks` |
| **Message Count Threshold** | 5 |

**Behavior:** The background worker scales to zero when no messages are pending on the Service Bus queue, eliminating idle costs. When 5 or more messages accumulate, KEDA creates a replica. Additional replicas are added as the queue depth grows, up to 5 total.

**Rationale:** Background processing is not latency-sensitive, so scaling to zero is acceptable. The message threshold of 5 means each replica processes approximately 5 messages before a new replica is warranted, balancing throughput against resource usage.

---

## Scaling Thresholds Summary

| Service | Scaler | Trigger Threshold | Min | Max | Scale to Zero |
|---|---|---|---|---|---|
| web-frontend | HTTP concurrent requests | 10 per instance | 1 | 10 | No |
| api-server | HTTP concurrent requests | 20 per instance | 2 | 20 | No |
| background-worker | Service Bus queue depth | 5 messages | 0 | 5 | Yes |

## Expected Behavior Under Load

### Low Traffic (< 10 concurrent requests)
- **web-frontend:** 1 replica
- **api-server:** 2 replicas
- **background-worker:** 0 replicas (unless queue has messages)

### Medium Traffic (~50 concurrent requests)
- **web-frontend:** ~5 replicas (50 / 10 = 5)
- **api-server:** ~3 replicas (50 / 20 ≈ 3)
- **background-worker:** Scales based on queue depth, independent of HTTP traffic

### High Traffic (~100+ concurrent requests)
- **web-frontend:** 10 replicas (capped at max)
- **api-server:** ~5–10 replicas
- **background-worker:** Up to 5 replicas if queue backlog builds

### Scale-Down Behavior
- KEDA evaluates metrics on a 30-second polling interval by default.
- Scale-down has a 5-minute stabilization window to avoid flapping.
- The background worker scales to zero after the queue is drained and the cooldown period expires.

## Load Testing

Use the provided load-test scripts to validate scaling behavior:

```powershell
# PowerShell
.\scripts\load-test.ps1 -WebFrontendUrl "https://<web-frontend-fqdn>" `
                        -ResourceGroup "<resource-group-name>"
```

```bash
# Bash
./scripts/load-test.sh --web-url "https://<web-frontend-fqdn>" \
                       --resource-group "<resource-group-name>"
```

Both scripts send batches of HTTP requests to the `/health` endpoint and then query Azure CLI for current replica counts after a 30-second wait.

## Infrastructure Files

| File | Purpose |
|---|---|
| `infrastructure/modules/container-app.bicep` | Container App module with `scalingRules` parameter |
| `infrastructure/modules/keda-scalers.bicep` | KEDA scaler definitions for Service Bus queue scaling |
| `infrastructure/deploy.bicep` | Orchestrator that configures scaling per service |
