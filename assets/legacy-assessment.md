# PawsCare Veterinary System — Legacy Assessment

> **Generated:** 2026-04-16  
> **Scope:** Full codebase analysis of the 3-VM on-premises PawsCare system  
> **Purpose:** Document architecture, anti-patterns, communication flows, container readiness, and migration risks

---

## 1. Current Architecture Analysis

### 1.1 System Topology

| VM | Role | OS | Runtime | IP Address | Key Services |
|----|------|----|---------|------------|--------------|
| VM1 | Web Frontend | Windows Server 2019 | ASP.NET Core 3.1 / IIS 10 | 10.0.1.10 | Web UI, SQL Server 2019, SMB File Share |
| VM2 | API Server | Ubuntu 20.04 | Node.js 14.x / Express | 10.0.1.20 | REST API, MongoDB 4.4 |
| VM3 | Background Worker | Ubuntu 20.04 | Python 3.8 / Celery + Pika | 10.0.1.30 | RabbitMQ 3.8, Async task processing |

### 1.2 Hardcoded IPs Found in Source Code

| IP / Address | File | Line(s) | Context |
|-------------|------|---------|---------|
| `http://10.0.1.20:3000` | `web-frontend/appsettings.json` | 14 | `ApiService.BaseUrl` — frontend → API calls |
| `\\10.0.1.10\documents` | `web-frontend/appsettings.json` | 17 | `FileStorage.Path` — SMB share for documents |
| `amqp://guest:guest@10.0.1.30:5672` | `api-server/server.js` | 17 | RabbitMQ connection fallback URI |
| `http://10.0.1.20:3000` | `background-worker/worker.py` | 21 | `API_SERVER_URL` default — worker → API |
| `\\\\10.0.1.10\\documents` | `background-worker/worker.py` | 93 | SMB share path in print statement |
| `\\\\10.0.1.10\\documents\\reports` | `background-worker/tasks/reports.py` | 34 | Hardcoded report output path |
| `10.0.1.10`, `10.0.1.20`, `10.0.1.30` | `infrastructure/README.md` | 34, 101–132 | Full topology documentation |

### 1.3 Legacy Anti-Patterns

#### Critical

| Anti-Pattern | Location | Details |
|-------------|----------|---------|
| **Static IP service discovery** | All services | Every cross-service call uses hardcoded `10.0.1.x` addresses. No DNS, no service registry. |
| **SMB file share as integration bus** | `api-server/routes/labResults.js:11-14`, `background-worker/tasks/lab_processing.py:47-54` | Lab results, X-rays, and PDF reports flow through `\\10.0.1.10\documents` — a single Windows SMB share. |
| **Everyone-FullAccess on SMB** | `infrastructure/vm-setup-scripts/setup-vm1.ps1:35` | `New-SmbShare … -FullAccess "Everyone"` — no authentication or authorization on the shared folder. |
| **Hardcoded credentials** | `docker-compose.yml:28`, `api-server/server.js:17` | `SA_PASSWORD=PawsCare123!`, RabbitMQ `guest:guest` in plain text. |

#### High

| Anti-Pattern | Location | Details |
|-------------|----------|---------|
| **EOL runtimes** | `.csproj`, `Dockerfile.legacy` files | .NET Core 3.1 (EOL Dec 2022), Node.js 14 (EOL Oct 2023), Python 3.8 (EOL Oct 2024). |
| **No centralized logging** | All VMs | IIS logs on VM1 (`C:\inetpub\logs`), flat files on VM2/VM3 (`/var/log`). No aggregation or search. |
| **No auto-scaling** | `infrastructure/README.md:175` | Fixed VM sizes (4 vCPU/8 GB, 2 vCPU/4 GB, 2 vCPU/4 GB) regardless of load. |
| **Mixed state stores** | System-wide | Data is split across SQL Server, MongoDB, RabbitMQ queues, and the SMB file share with no unified strategy. |
| **Deprecated `body-parser` middleware** | `api-server/server.js:12` | Should use built-in `express.json()` instead. |
| **No circuit breakers or retries** | All inter-service calls | A single VM failure cascades to the entire system. |

#### Medium

| Anti-Pattern | Location | Details |
|-------------|----------|---------|
| **Manual SSL certificate management** | `infrastructure/README.md:183` | Certificates hand-deployed on IIS. |
| **Cron-based scheduling** | `background-worker/crontab` | Rigid time-based triggers instead of event-driven processing. |
| **Manual patching windows** | `infrastructure/README.md:136-144` | 2:00–6:00 AM, 2nd Tuesday — 30-45 min downtime per VM. |
| **No graceful shutdown handlers** | `worker.py`, `server.js` | Limited SIGTERM handling; risk of data loss on restart. |

### 1.4 Dependency Versions

#### Web Frontend — `web-frontend/PawsCare.Web.csproj`

| Package | Version | Status |
|---------|---------|--------|
| Target Framework | `netcoreapp3.1` | ⛔ EOL Dec 2022 |
| Microsoft.EntityFrameworkCore | 3.1.32 | ⛔ EOL |
| Microsoft.EntityFrameworkCore.SqlServer | 3.1.32 | ⛔ EOL |
| Microsoft.EntityFrameworkCore.Design | 3.1.32 | ⛔ EOL |
| Newtonsoft.Json | 13.0.1 | ✅ Active |

#### API Server — `api-server/package.json`

| Package | Version | Status |
|---------|---------|--------|
| Node.js runtime | 14.x | ⛔ EOL Oct 2023 |
| express | ^4.17.1 | ⚠️ Outdated (current 4.18+) |
| mongoose | ^5.13.15 | ⚠️ Outdated (current 7.x) |
| body-parser | ^1.19.0 | ⚠️ Deprecated — use `express.json()` |
| amqplib | ^0.10.3 | ⚠️ Outdated |
| cors | ^2.8.5 | ✅ Active |
| multer | ^1.4.3 | ✅ Active |
| dotenv | ^10.0.0 | ✅ Active |

#### Background Worker — `background-worker/requirements.txt`

| Package | Version | Status |
|---------|---------|--------|
| Python runtime | 3.8 | ⛔ EOL Oct 2024 |
| celery | 5.2.7 | ✅ (not actively used — pika handles queues) |
| pika | 1.3.1 | ✅ Active |
| requests | 2.28.1 | ✅ Active |
| Pillow | 9.3.0 | ⚠️ Outdated (current 10.x+) |
| reportlab | 3.6.12 | ✅ Active |

#### Infrastructure

| Component | Version | Status |
|-----------|---------|--------|
| SQL Server | 2019 | ⚠️ EOL Jan 2029 |
| MongoDB | 4.4 | ⛔ EOL Feb 2024 |
| RabbitMQ | 3.8 | ⛔ EOL Jul 2024 |
| Windows Server | 2019 | ⚠️ Mainstream support ended |
| Ubuntu | 20.04 LTS | ✅ Supported until Apr 2030 |

---

## 2. Service Communication Map

### 2.1 Diagram

```
                          ┌────────────────────────────────┐
                          │       Users / Browsers         │
                          └──────────────┬─────────────────┘
                                         │ HTTPS :443
                                         ▼
              ┌──────────────────────────────────────────────────┐
              │  VM1 — Web Frontend (10.0.1.10)                  │
              │  ASP.NET Core 3.1 on IIS 10 / Windows Server     │
              │  ┌─────────────┐   ┌──────────────────────────┐  │
              │  │ SQL Server  │   │ SMB Share                │  │
              │  │ :1433       │   │ \\10.0.1.10\documents     │  │
              │  └─────────────┘   └──────────────────────────┘  │
              └───────────┬────────────────▲──────▲──────────────┘
                          │ HTTP :3000     │ SMB  │ SMB
                          ▼                │ :445 │ :445
              ┌────────────────────────────┴──────┤──────────────┐
              │  VM2 — API Server (10.0.1.20)     │              │
              │  Node.js 14 + Express             │              │
              │  ┌──────────┐                     │              │
              │  │ MongoDB  │                     │              │
              │  │ :27017   │                     │              │
              │  └──────────┘                     │              │
              └───────────┬───────────────────────┘──────────────┘
                          │ AMQP :5672
                          ▼
              ┌──────────────────────────────────────────────────┐
              │  VM3 — Background Worker (10.0.1.30)             │
              │  Python 3.8 + Pika                               │
              │  ┌────────────┐                                  │
              │  │ RabbitMQ   │                                  │
              │  │ :5672      │                                  │
              │  └────────────┘                                  │
              └──────────────────────────────────────────────────┘
```

### 2.2 Communication Flows

| # | From | To | Protocol | Port | Path / Queue | Purpose |
|---|------|----|----------|------|-------------|---------|
| 1 | Browser | VM1 (Web Frontend) | HTTPS | 443 | `/` | Serve MVC views |
| 2 | VM1 (Web Frontend) | VM2 (API Server) | HTTP | 3000 | `/api/patients`, `/api/appointments`, `/api/prescriptions` | REST API calls for data |
| 3 | VM2 (API Server) | VM2 (MongoDB) | TCP | 27017 | — | Read/write pet & appointment data |
| 4 | VM2 (API Server) | VM3 (RabbitMQ) | AMQP | 5672 | `appointment_reminders`, `lab_results` | Publish async tasks |
| 5 | VM3 (Worker) | VM3 (RabbitMQ) | AMQP | 5672 | `appointment_reminders`, `lab_results` | Consume messages |
| 6 | VM3 (Worker) | VM2 (API Server) | HTTP | 3000 | `/api/*` | Verification & status updates |
| 7 | VM2 (API Server) | VM1 (SMB Share) | SMB | 445 | `\\10.0.1.10\documents` | Upload lab results |
| 8 | VM3 (Worker) | VM1 (SMB Share) | SMB | 445 | `\\10.0.1.10\documents\reports` | Write generated PDF reports |
| 9 | VM1 (Web Frontend) | VM1 (SQL Server) | TCP | 1433 | — | User auth & session data |

### 2.3 Message Queues

| Queue Name | Publisher | Consumer | Payload |
|-----------|-----------|----------|---------|
| `appointment_reminders` | API Server (VM2) | Worker (VM3) | Appointment details for reminder notifications |
| `lab_results` | API Server (VM2) | Worker (VM3) | Lab result data for processing and PDF generation |

---

## 3. Container Readiness Assessment

### 3.1 Web Frontend (VM1) — ASP.NET Core 3.1

| Dimension | Status | Finding |
|-----------|--------|---------|
| **Runtime** | 🔴 Not Ready | .NET Core 3.1 is EOL. Must upgrade to .NET 8+ for supported container images. |
| **Configuration** | 🔴 Not Ready | `appsettings.json` has hardcoded IPs and SMB paths. Needs env-var overrides. |
| **State** | 🟡 Partial | SQL Server holds persistent state — can be externalized to Azure SQL. IIS session state may be in-process. |
| **File System** | 🔴 Not Ready | Depends on local SMB share at `\\10.0.1.10\documents`. Must migrate to Azure Blob Storage or equivalent. |
| **Logging** | 🔴 Not Ready | IIS logs to `C:\inetpub\logs`. Must redirect to stdout/stderr for container log drivers. |
| **Health Checks** | 🔴 Not Ready | No health-check endpoint exposed. Container orchestrators need `/healthz` and `/readyz`. |
| **Dockerfile** | 🟢 Exists | `Dockerfile` present using `mcr.microsoft.com/dotnet/aspnet:3.1`. Needs base image update. |
| **Secrets** | 🔴 Not Ready | SQL connection string with password in `appsettings.json`. Needs secrets management. |

**Modernization Dockerfile exists:** `web-frontend/Dockerfile` (targets .NET 8 — good starting point)  
**Legacy Dockerfile exists:** `web-frontend/Dockerfile.legacy` (IIS-based — illustrates the original setup)

### 3.2 API Server (VM2) — Node.js 14 / Express

| Dimension | Status | Finding |
|-----------|--------|---------|
| **Runtime** | 🟡 Partial | Node.js 14 is EOL. Upgrade to Node.js 20 LTS. Express and Mongoose also need major version bumps. |
| **Configuration** | 🟡 Partial | Uses `dotenv` + env vars with hardcoded IP fallbacks in `server.js:16-17`. Remove fallbacks. |
| **State** | 🟢 Ready | MongoDB is the sole data store — can be externalized to Azure Cosmos DB for MongoDB. |
| **File System** | 🔴 Not Ready | `multer` uploads go to SMB share (`routes/labResults.js:11-14`). Needs Azure Blob migration. |
| **Logging** | 🟡 Partial | Uses `console.log` — writes to stdout, which is container-friendly. But no structured logging. |
| **Health Checks** | 🟡 Partial | Basic `/health` endpoint exists (`server.js:68-74`). Needs readiness and liveness separation. |
| **Dockerfile** | 🟢 Exists | `Dockerfile` present. Needs Node.js base image version update. |
| **Secrets** | 🔴 Not Ready | RabbitMQ credentials hardcoded as `guest:guest` in fallback string. |

### 3.3 Background Worker (VM3) — Python 3.8

| Dimension | Status | Finding |
|-----------|--------|---------|
| **Runtime** | 🟡 Partial | Python 3.8 is EOL. Upgrade to Python 3.12+. |
| **Configuration** | 🔴 Not Ready | Hardcoded `API_SERVER_URL` and SMB paths in `worker.py` and `tasks/reports.py`. |
| **State** | 🟡 Partial | RabbitMQ runs on the same VM. Must externalize to Azure Service Bus or managed RabbitMQ. |
| **File System** | 🔴 Not Ready | Writes PDFs and reports to SMB share. Must migrate to blob storage. |
| **Logging** | 🟡 Partial | Uses `print()` — stdout-friendly but unstructured. |
| **Health Checks** | 🔴 Not Ready | No health endpoint. Worker processes need liveness probes (e.g., heartbeat check). |
| **Dockerfile** | 🟢 Exists | `Dockerfile` present. Base image needs version update. |
| **Cron Jobs** | 🔴 Not Ready | `crontab` file schedules tasks. Must convert to Azure Container Apps jobs or KEDA-based scaling. |
| **Secrets** | 🔴 Not Ready | RabbitMQ URL constructed with credentials in code. |

### 3.4 Summary Scorecard

| Service | Ready | Partial | Not Ready | Overall |
|---------|-------|---------|-----------|---------|
| Web Frontend | 1 | 1 | 6 | 🔴 Major work needed |
| API Server | 2 | 3 | 2 | 🟡 Moderate work needed |
| Background Worker | 1 | 3 | 4 | 🔴 Major work needed |

---

## 4. Migration Risk Matrix

### 4.1 Risk Register

| ID | Risk | Likelihood | Impact | Severity | Affected Services | Mitigation |
|----|------|-----------|--------|----------|-------------------|------------|
| R1 | **SMB share removal breaks file workflows** | High | Critical | 🔴 Critical | API Server, Worker, Frontend | Migrate to Azure Blob Storage with SDK; implement adapter pattern for file I/O. Test all upload/download paths. |
| R2 | **Hardcoded IPs cause runtime failures** | High | Critical | 🔴 Critical | All | Replace all IPs with environment variables. Use container service names for discovery. Grep for `10.0.1.` across entire codebase. |
| R3 | **.NET Core 3.1 → .NET 8 migration breaks APIs** | Medium | High | 🟠 High | Web Frontend | Incremental upgrade path (3.1 → 6.0 → 8.0). Test all controllers and views. `Startup.cs` → `Program.cs` pattern changes. |
| R4 | **MongoDB 4.4 → Cosmos DB compatibility issues** | Medium | High | 🟠 High | API Server | Audit all Mongoose queries for Cosmos DB compatibility. Test aggregation pipelines. Check index support. |
| R5 | **RabbitMQ → Azure Service Bus protocol differences** | Medium | High | 🟠 High | API Server, Worker | AMQP 0-9-1 (RabbitMQ) vs AMQP 1.0 (Service Bus). Requires client library changes in both Node.js and Python. |
| R6 | **Data migration — SQL Server + MongoDB** | Medium | High | 🟠 High | All | Plan offline migration window. Validate data integrity. Schema compatibility between SQL Server → Azure SQL and MongoDB → Cosmos DB. |
| R7 | **Credential exposure during migration** | Medium | High | 🟠 High | All | Implement Azure Key Vault before migration. Rotate all credentials (`PawsCare123!`, `guest:guest`). |
| R8 | **Cron job conversion to Container Apps jobs** | Low | Medium | 🟡 Medium | Worker | Map each cron entry to an Azure Container Apps job with KEDA or time-based triggers. Test scheduling accuracy. |
| R9 | **Node.js 14 → 20 breaking changes** | Low | Medium | 🟡 Medium | API Server | Test with `--experimental-vm-modules` flag removed. Check for deprecated APIs. Mongoose 5 → 7 requires schema review. |
| R10 | **Loss of IIS-specific features** | Low | Medium | 🟡 Medium | Web Frontend | Review IIS URL rewrite rules, Windows Auth, and static file serving. Replace with Kestrel equivalents. |
| R11 | **Downtime during cutover** | Medium | Medium | 🟡 Medium | All | Use blue-green deployment. Run legacy and containerized systems in parallel during transition. DNS-based traffic switching. |
| R12 | **Monitoring gap during migration** | Low | Low | 🟢 Low | All | Deploy Azure Monitor + Application Insights before migration. Instrument new containers from day one. |

### 4.2 Risk Heat Map

```
                    IMPACT
              Low    Medium    High    Critical
           ┌────────┬─────────┬───────┬──────────┐
    High   │        │         │       │ R1, R2   │
           ├────────┼─────────┼───────┼──────────┤
  L Medium │        │  R11    │R3,R4, │          │
  I        │        │         │R5,R6, │          │
  K        │        │         │  R7   │          │
  E        ├────────┼─────────┼───────┼──────────┤
  L Low    │  R12   │ R8,R9,  │       │          │
  I        │        │  R10    │       │          │
  H        ├────────┼─────────┼───────┼──────────┤
  O        │        │         │       │          │
  O Never  │        │         │       │          │
  D        └────────┴─────────┴───────┴──────────┘
```

### 4.3 Recommended Migration Order

Based on the risk analysis, the recommended migration sequence is:

1. **Phase 0 — Prep (2-3 weeks)**
   - Externalize all configuration (replace hardcoded IPs with env vars)
   - Set up Azure Key Vault for secrets
   - Deploy Azure Monitor / Application Insights
   - Provision Azure Blob Storage to replace SMB share

2. **Phase 1 — API Server (2-3 weeks)**  
   *Lowest coupling, existing Dockerfile, partial container readiness*
   - Upgrade Node.js 14 → 20, Mongoose 5 → 7
   - Replace SMB file uploads with Azure Blob SDK
   - Deploy to Azure Container Apps
   - Point to Azure Cosmos DB for MongoDB

3. **Phase 2 — Background Worker (2-3 weeks)**  
   *Depends on API Server and message broker migration*
   - Upgrade Python 3.8 → 3.12
   - Replace RabbitMQ with Azure Service Bus (or managed RabbitMQ)
   - Convert cron jobs to Container Apps jobs
   - Replace SMB writes with Azure Blob SDK

4. **Phase 3 — Web Frontend (3-4 weeks)**  
   *Highest effort due to .NET Core 3.1 → .NET 8 upgrade*
   - Upgrade to .NET 8 (staged: 3.1 → 6.0 → 8.0)
   - Replace SQL Server with Azure SQL
   - Remove IIS dependency (use Kestrel)
   - Replace SMB share references with Azure Blob SDK
   - Deploy to Azure Container Apps

5. **Phase 4 — Decommission (1 week)**
   - Verify all data migrated and services healthy
   - Redirect DNS
   - Shut down VMs
   - Estimated monthly cost reduction: ~$370/mo VMs → consumption-based Container Apps

---

## Appendix A: Cost Comparison

| Resource | Current (VMs) | Estimated (Container Apps) |
|----------|---------------|---------------------------|
| VM1 (4 vCPU, 8 GB) | $150/mo | — |
| VM2 (2 vCPU, 4 GB) | $75/mo | — |
| VM3 (2 vCPU, 4 GB) | $75/mo | — |
| Storage | $40-70/mo | — |
| **Container Apps (3 services)** | — | ~$50-100/mo (consumption) |
| **Azure SQL** | — | ~$30/mo (Basic) |
| **Cosmos DB** | — | ~$25/mo (serverless) |
| **Azure Service Bus** | — | ~$10/mo (Basic) |
| **Blob Storage** | — | ~$5/mo |
| **Total** | **~$370/mo** | **~$120-170/mo** |

## Appendix B: Files Scanned

All source files were scanned across the three service directories, infrastructure scripts, and configuration files:

- `web-frontend/` — `appsettings.json`, `Program.cs`, `Startup.cs`, `PawsCare.Web.csproj`, `Dockerfile`, `Dockerfile.legacy`, all Controllers, Data, Models, Services, and Views
- `api-server/` — `server.js`, `package.json`, `seed.js`, `Dockerfile`, `Dockerfile.legacy`, all routes and models
- `background-worker/` — `worker.py`, `requirements.txt`, `crontab`, `Dockerfile`, `Dockerfile.legacy`, all tasks
- `infrastructure/` — `README.md`, all vm-setup-scripts
- Root — `docker-compose.yml`, `README.md`, `README-LEGACY.md`, `APPMODLAB.MD`
