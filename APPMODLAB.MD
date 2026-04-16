---
title: "VMs to Azure Container Apps"
description: "Containerize VM workloads and deploy to Container Apps with Dapr, KEDA auto-scaling & Service Bus"
authors: ["marconsilva"]
category: "Infra Modernization"
industry: "Healthcare & Life Sciences"
services: ["Azure Container Apps", "Azure Container Registry", "Azure Service Bus", "Azure Cosmos DB", "Azure Blob Storage"]
languages: [".NET", "JavaScript", "Python"]
frameworks: ["ASP.NET Core", "Express", "Celery"]
modernizationTools: ["Docker", "Dapr", "KEDA"]
agenticTools: []
tags: ["containerization", "container-apps", "dapr", "keda", "multi-language"]
extensions: ["github.copilot"]
thumbnail: ""
video: ""
version: "1.0.0"
---

## Overview

This lab guides you through containerizing a three-VM on-premises veterinary network system and deploying it to Azure Container Apps with Dapr, KEDA auto-scaling, and Service Bus integration.

## Understanding the Legacy Architecture

The PawsCare Veterinary Network is a multi-tier legacy system originally running across three on-premises VMs. The following sections show the system running locally via Docker Compose, simulating the original architecture.

### VM 1 — Web Frontend (ASP.NET Core)

The web frontend dashboard shows the PawsCare Veterinary Network UI with navigation for Dashboard, Appointments, Patients, and Owners. Quick action buttons allow booking appointments, adding patients, and registering pet owners.

![Web Frontend Dashboard](assets/screenshots/web-frontend-dashboard.png)

### VM 2 — API Server (Node.js + Express)

The API server identifies itself as the legacy VM-2 instance running on simulated IP 10.0.1.20:

![API Server Root](assets/screenshots/api-server-root.png)

The health check endpoint confirms MongoDB and RabbitMQ connectivity:

![API Server Health Check](assets/screenshots/api-server-health.png)

The patients API returns 12 pre-seeded pet records (dogs and cats) with full medical profile data:

![API Server Patients](assets/screenshots/api-server-patients.png)

The appointments API returns 5 scheduled veterinary appointments across multiple specialists:

![API Server Appointments](assets/screenshots/api-server-appointments.png)

### VM 3 — Background Worker Infrastructure (Python + RabbitMQ)

The RabbitMQ management console shows the message broker running with active connections from both the API server and the background worker:

![RabbitMQ Management Dashboard](assets/screenshots/rabbitmq-management-dashboard.png)

The queues view shows the two durable message queues (`appointment_reminders` and `lab_results`) that the background worker consumes:

![RabbitMQ Queues](assets/screenshots/rabbitmq-queues.png)

The RabbitMQ management login page provides access to the broker administration interface:

![RabbitMQ Login Page](assets/screenshots/rabbitmq-management-login.png)

## Screenshots Reference

| Screenshot | Description |
|---|---|
| ![Web Frontend](assets/screenshots/web-frontend-dashboard.png) | VM 1 — ASP.NET Core frontend dashboard |
| ![API Root](assets/screenshots/api-server-root.png) | VM 2 — API server root endpoint |
| ![API Health](assets/screenshots/api-server-health.png) | VM 2 — Health check endpoint |
| ![API Patients](assets/screenshots/api-server-patients.png) | VM 2 — Patients API response |
| ![API Appointments](assets/screenshots/api-server-appointments.png) | VM 2 — Appointments API response |
| ![RabbitMQ Dashboard](assets/screenshots/rabbitmq-management-dashboard.png) | VM 3 — RabbitMQ management console |
| ![RabbitMQ Queues](assets/screenshots/rabbitmq-queues.png) | VM 3 — Message queues view |
| ![RabbitMQ Login](assets/screenshots/rabbitmq-management-login.png) | VM 3 — RabbitMQ login page |

## Solution Walkthrough

The `solution-final` branch contains the complete modernized solution, built step-by-step using GitHub Copilot CLI. Each step is tagged and has captured CLI output in `assets/outputs/`.

### Branch & Tags

```
git checkout solution-final
```

| Tag | Commit | Description |
|-----|--------|-------------|
| `step-01-explore-legacy` | Step 01 | Legacy system analysis and assessment |
| `step-02-create-dockerfiles` | Step 02 | Optimized multi-stage Dockerfiles (.NET 8, Node 18, Python 3.11) |
| `step-03-local-container-testing` | Step 03 | Docker Compose with healthchecks and test scripts |
| `step-04-add-dapr` | Step 04 | Dapr sidecars for service invocation and pub/sub |
| `step-05-azure-services` | Step 05 | Azure Cosmos DB, Service Bus, Blob Storage integration |
| `step-06-container-apps-deploy` | Step 06 | Bicep templates and GitHub Actions for Container Apps |
| `step-07-configure-scaling` | Step 07 | KEDA auto-scaling rules for HTTP and queue depth |
| `step-08-validate-e2e` | Step 08 | End-to-end validation scripts and architecture docs |

### CLI Prompts Used

Each step was executed via `gh copilot` with the `--allow-all-tools --yolo` flags. Full CLI output is captured in:

| Step | Output File |
|------|-------------|
| 01 — Explore Legacy | `assets/outputs/step-01-explore-legacy.txt` |
| 02 — Create Dockerfiles | `assets/outputs/step-02-create-dockerfiles.txt` |
| 03 — Local Container Testing | `assets/outputs/step-03-local-container-testing.txt` |
| 04 — Add Dapr | `assets/outputs/step-04-add-dapr.txt` |
| 05 — Azure Services | `assets/outputs/step-05-azure-services.txt` |
| 06 — Container Apps Deploy | `assets/outputs/step-06-container-apps-deploy.txt` |
| 07 — Configure Scaling | `assets/outputs/step-07-configure-scaling.txt` |
| 08 — Validate E2E | `assets/outputs/step-08-validate-e2e.txt` |

### Key Artifacts Produced

- **`assets/legacy-assessment.md`** — Full VM-to-container readiness assessment
- **`assets/architecture-after.md`** — Modernized architecture documentation
- **`assets/migration-checklist.md`** — Before/after migration checklist
- **`assets/scaling-config.md`** — KEDA scaling rules and thresholds
- **`infrastructure/main.bicep`** — Core Azure infrastructure (ACR, Container Apps Environment)
- **`infrastructure/deploy.bicep`** — Full deployment orchestration with all 3 services
- **`infrastructure/azure-services.bicep`** — Azure Cosmos DB, Service Bus, Blob Storage, SQL
- **`.github/workflows/deploy.yml`** — CI/CD pipeline for building and deploying
- **`dapr/`** — Dapr component configs (local and Azure variants)
- **`scripts/`** — Deploy, test, load-test, and E2E validation scripts (PS1 + SH)

### Reproducing the Solution

```bash
# Clone and explore
git clone https://github.com/EmeaAppGbb/appmodlab-on-prem-vms-to-container-apps.git
cd appmodlab-on-prem-vms-to-container-apps

# Run legacy system locally
docker compose up -d

# Run local tests
./scripts/test-local.ps1   # Windows
./scripts/test-local.sh    # Linux/macOS

# Deploy to Azure (requires Azure CLI login)
./scripts/deploy-azure.ps1 # Windows
./scripts/deploy-azure.sh  # Linux/macOS

# Run E2E validation
./scripts/validate-e2e.ps1 # Windows
./scripts/validate-e2e.sh  # Linux/macOS
```
