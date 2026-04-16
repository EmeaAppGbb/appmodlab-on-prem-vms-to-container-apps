# 🌟 VMs → CONTAINER APPS 🌟

```
███████╗██████╗  ██████╗ ███╗   ███╗    ██╗   ██╗███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗████╗ ████║    ██║   ██║████╗ ████║██╔════╝
█████╗  ██████╔╝██║   ██║██╔████╔██║    ██║   ██║██╔████╔██║███████╗
██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║    ██║   ██║██║╚██╔╝██║╚════██║
██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ╚██████╔╝██║ ╚═╝ ██║███████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝     ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                          
                        ████████╗ ██████╗ 
                        ╚══██╔══╝██╔═══██╗
                           ██║   ██║   ██║
                           ██║   ██║   ██║
                           ██║   ╚██████╔╝
                           ╚═╝    ╚═════╝ 
                                          
     ██████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗ ███████╗
    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗██╔════╝
    ██║     ██║   ██║██╔██╗ ██║   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝███████╗
    ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██║  ██║╚════██║
    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║███████║
     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚══════╝
```

> 🎮 **UPGRADE YOUR INFRASTRUCTURE** 🎮  
> From horse carts to spaceships! Transform static VMs into auto-scaling containerized glory! 🚀✨

---

## 🌈 OVERVIEW

**Welcome to the future, time traveler!** 🕹️

Remember when deploying apps meant:
- 🐌 Waiting for VMs to boot (grab a coffee... or two)
- 🔧 Manual patching every Tuesday at 3 AM
- 💸 Paying for VMs that sit idle 23 hours a day
- 🔥 Hardcoded IPs everywhere like it's 1999

**LEVEL UP!** This lab transforms a crusty three-VM veterinary clinic system into a sleek, auto-scaling, container-powered masterpiece running on **Azure Container Apps** with **Dapr** magic! 🎯

### 🏥 Meet PawsCare Veterinary Network

**Legacy System (aka "The Before Times"):**
- 🖥️ **VM 1:** Windows Server 2019 + IIS + ASP.NET Core (The Web Frontend)
- 🖥️ **VM 2:** Ubuntu + Node.js + Express + MongoDB (The API Server)
- 🖥️ **VM 3:** Ubuntu + Python + Celery + RabbitMQ (The Background Worker)
- 📁 SMB file shares (because it's 2015 forever)
- 🔗 Hardcoded IPs (10.0.1.10, anyone?)
- 😭 Manual everything

**Target System (aka "The Glow-Up"):**
- 📦 **Container 1:** ASP.NET Core in a Docker container
- 📦 **Container 2:** Node.js API in a Docker container
- 📦 **Container 3:** Python worker in a Docker container
- ☁️ **Azure Container Apps** (serverless magic)
- 🎭 **Dapr** for service mesh awesomeness
- 📊 **Azure Cosmos DB** + **Azure SQL**
- 📨 **Azure Service Bus** (bye RabbitMQ!)
- 🗂️ **Azure Blob Storage** (bye SMB!)
- ⚡ **KEDA auto-scaling** (scale to zero, scale to hero!)

---

## 🎯 WHAT YOU'LL LEARN

By the end of this retro quest, you'll master:

✅ **VM-to-Container Migration Strategy** 🔄  
   Analyze legacy apps and plan containerization like a pro

✅ **Multi-Stage Dockerfiles** 🐳  
   Build optimized images for .NET, Node.js, and Python

✅ **Dapr Building Blocks** 🎭  
   Service discovery, pub/sub, state management—no more hardcoded IPs!

✅ **Azure Container Apps Architecture** 🏗️  
   Deploy serverless containers with built-in ingress and TLS

✅ **KEDA Auto-Scaling** 📈  
   Configure HTTP and queue-based scaling rules

✅ **Azure Service Integration** ☁️  
   Blob Storage, Service Bus, Cosmos DB, and Azure SQL

---

## 🎮 PREREQUISITES

**Before you press START:**

- ✅ **Docker Desktop** installed and running
- ✅ **Azure CLI** (`az`) installed
- ✅ **Azure Subscription** with Contributor access
- ✅ **Basic container knowledge** (what's a Dockerfile?)
- ✅ **Familiarity with** .NET, Node.js, **or** Python (pick your favorite!)
- ✅ **GitHub Copilot CLI** (for the ultimate dev experience)

---

## 🚀 QUICK START

```bash
# 🎪 CLONE THE RETRO ARCADE
git clone https://github.com/EmeaAppGbb/appmodlab-on-prem-vms-to-container-apps.git
cd appmodlab-on-prem-vms-to-container-apps

# 🕹️ CHECKOUT THE LEGACY SYSTEM
git checkout legacy

# 🐳 BOOT UP THE "VMs" (via Docker Compose)
docker-compose up -d

# 🌐 OPEN THE WEB APP
# Navigate to http://localhost:8080

# 🎉 EXPLORE THE OLD WORLD
# Book appointments, upload lab results, see the VM-based architecture in action

# 🚀 READY TO MODERNIZE?
# Follow the APPMODLAB.md for step-by-step containerization!
```

---

## 📂 PROJECT STRUCTURE

```
appmodlab-on-prem-vms-to-container-apps/
├── 📜 README.md                         ← You are here! 🌟
├── 📘 APPMODLAB.md                      ← Full lab walkthrough
├── 📋 QUICKSTART.md                     ← Quick-start guide
│
├── 🌐 web-frontend/                     ← ASP.NET Core 8 MVC (Container 1)
│   ├── PawsCare.Web.csproj
│   ├── Program.cs / Startup.cs
│   ├── Controllers/ Views/ Services/
│   ├── appsettings.json                 ← Dapr + SQL config
│   ├── Dockerfile                       ← Multi-stage .NET 8 build
│   └── Dockerfile.legacy                ← Original VM-style build
│
├── 🔌 api-server/                       ← Node.js 18 + Express (Container 2)
│   ├── package.json / server.js
│   ├── routes/                          ← patients, appointments, labresults, prescriptions
│   ├── models/                          ← Mongoose schemas
│   ├── Dockerfile                       ← Optimized Node.js image
│   └── Dockerfile.legacy
│
├── ⚙️  background-worker/                ← Python 3.11 + Flask (Container 3)
│   ├── worker.py                        ← Dapr subscriber + RabbitMQ fallback
│   ├── tasks/                           ← lab_processing.py, reminders.py
│   ├── requirements.txt
│   ├── Dockerfile                       ← Multi-stage Python build
│   └── Dockerfile.legacy
│
├── 🎭 dapr/                             ← Dapr configuration
│   ├── config.yaml                      ← Tracing (Zipkin) + metrics
│   └── components/
│       ├── pubsub.yaml                  ← RabbitMQ (local dev)
│       ├── azure-pubsub.yaml            ← Azure Service Bus (prod)
│       ├── statestore.yaml              ← MongoDB (local dev)
│       ├── azure-statestore.yaml        ← Cosmos DB (prod)
│       └── azure-blobstore.yaml         ← Azure Blob Storage binding
│
├── 🏗️  infrastructure/                   ← Bicep IaC templates
│   ├── main.bicep                       ← Log Analytics, ACR, Container Apps Env
│   ├── deploy.bicep                     ← Container App definitions + KEDA rules
│   ├── azure-services.bicep             ← Cosmos DB, Service Bus, Blob, SQL
│   ├── modules/                         ← Reusable Bicep modules
│   └── vm-setup-scripts/                ← Legacy VM provisioning (reference)
│
├── 🧪 scripts/                           ← Automation & testing
│   ├── deploy-azure.ps1 / .sh           ← Full Azure deployment pipeline
│   ├── test-local.ps1 / .sh             ← Local container smoke tests
│   ├── validate-e2e.ps1 / .sh           ← End-to-end integration tests
│   └── load-test.ps1 / .sh              ← KEDA auto-scaling load tests
│
├── 📊 assets/                            ← Documentation & diagrams
│   ├── architecture-after.md            ← Modernized architecture reference
│   ├── migration-checklist.md           ← 50-item legacy → modern checklist
│   ├── legacy-assessment.md             ← Legacy system analysis
│   ├── scaling-config.md                ← KEDA scaling rules reference
│   └── screenshots/                     ← UI and API screenshots
│
├── 🐳 docker-compose.yml                ← Legacy VM simulation (MongoDB, RabbitMQ, SQL)
├── 🐳 docker-compose.dapr.yml           ← Dapr sidecar overlay (Zipkin + sidecars)
└── 🐳 docker-compose.override.yml       ← Dev overrides (source mounts, debug)
```

---

## 🖥️ LEGACY STACK (The Old World)

### **Three VMs Walk Into a Bar...**

**VM 1: The Web Frontend** 🪟
- Windows Server 2019
- IIS 10 hosting ASP.NET Core 3.1 MVC
- SQL Server 2019 (shared with the app)
- 4 vCPU, 8GB RAM (always on, always billing)
- IP: `10.0.1.10`

**VM 2: The API Server** 🐧
- Ubuntu 20.04
- Node.js 14.x + Express 4.x
- MongoDB 4.4 for pet records
- 2 vCPU, 4GB RAM
- IP: `10.0.1.20`

**VM 3: The Background Worker** 🔧
- Ubuntu 20.04
- Python 3.8 + Celery + RabbitMQ
- Cron jobs for appointment reminders
- 2 vCPU, 4GB RAM
- IP: `10.0.1.30`

### **Anti-Patterns Spotted!** 🚨

- ❌ Hardcoded IPs everywhere
- ❌ No auto-scaling (overpay for idle resources)
- ❌ Manual patching nightmares
- ❌ SMB file shares (it's not 2010!)
- ❌ Single-instance RabbitMQ (no HA)
- ❌ Manual SSL certificate deployment
- ❌ No health checks
- ❌ Monolithic VM updates

---

## 🚀 TARGET ARCHITECTURE (The Glow-Up)

### **Container-Powered Paradise!** ✨

```
┌─────────────────────────────────────────────────────────────┐
│             🌐 AZURE CONTAINER APPS ENVIRONMENT             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📦 Web Frontend Container    📦 API Server Container       │
│     ├── ASP.NET Core              ├── Node.js + Express    │
│     ├── Dapr Sidecar              ├── Dapr Sidecar         │
│     └── Auto-scale (HTTP)         └── Auto-scale (HTTP)    │
│                                                             │
│  📦 Background Worker Container                             │
│     ├── Python + Celery                                     │
│     ├── Dapr Sidecar                                        │
│     └── Auto-scale (Queue Depth)                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ├── 🗂️ Azure Blob Storage
                            ├── 📨 Azure Service Bus
                            ├── 📊 Azure Cosmos DB (MongoDB API)
                            └── 🗄️ Azure SQL Database
```

### **Key Upgrades** 🎉

| Legacy | Modern | Benefit |
|--------|--------|---------|
| 🖥️ VMs | 📦 Containers | **CONTAINER BUILT** 📦 Faster deployments! |
| 🔗 Hardcoded IPs | 🎭 Dapr Service Discovery | **PODS ONLINE** 🚀 Dynamic routing! |
| 📁 SMB Shares | 🗂️ Azure Blob Storage | **CLOUD NATIVE** ☁️ Scalable storage! |
| 🐰 RabbitMQ | 📨 Azure Service Bus | **MESSAGING UPGRADED** 📨 Enterprise-grade! |
| 🔧 Manual Scaling | ⚡ KEDA Auto-Scaling | **SCALING UP** ⬆️ Scale to zero! |
| 🔑 Manual SSL | 🔒 Built-in TLS | **SECURE BY DEFAULT** 🔒 Easy TLS! |
| 💰 Always-on VMs | 🌙 Serverless Containers | **COST OPTIMIZED** 💸 Pay per use! |

---

## 🎯 LAB WALKTHROUGH (Using Copilot CLI)

### **🎮 LEVEL 1: Explore the Legacy System**

```bash
# Start the "VM simulation" (Docker Compose)
docker-compose up -d

# Check what's running
docker ps

# 🔍 Explore the hardcoded IPs in the config
gh copilot suggest "show me hardcoded IP addresses in appsettings.json"

# 🌐 Test the web app
curl http://localhost:8080

# 📊 Book an appointment, upload a lab result
# See how the three "VMs" communicate
```

**LEGACY SYSTEM ONLINE** 🟢

---

### **🎮 LEVEL 2: Containerize the Apps**

```bash
# Switch to the containerization step
git checkout step-1-containerize

# 🐳 Build the Docker images
gh copilot suggest "build docker images for all three applications"

# Example output:
# CONTAINER BUILT 📦 web-frontend:latest
# CONTAINER BUILT 📦 api-server:latest
# CONTAINER BUILT 📦 background-worker:latest

# 🧪 Test locally
docker run -p 8080:80 web-frontend:latest
```

**IMAGES READY** 🐳

---

### **🎮 LEVEL 3: Local Container Testing**

```bash
# Switch to Docker Compose step
git checkout step-2-compose

# 🚀 Run all containers together
docker-compose -f docker-compose.containers.yml up

# ✅ Verify service communication
gh copilot suggest "test if containers can talk to each other"

# 🎉 All three containers running!
```

**PODS ONLINE** 🚀

---

### **🎮 LEVEL 4: Add Dapr Magic**

```bash
# Switch to Dapr integration step
git checkout step-3-dapr-integration

# 🎭 Initialize Dapr locally
dapr init

# 🔧 Configure Dapr components
gh copilot suggest "configure dapr service invocation and pub/sub"

# 🚀 Run with Dapr sidecars
dapr run --app-id web-frontend --app-port 8080 ...
dapr run --app-id api-server --app-port 3000 ...
dapr run --app-id background-worker ...

# ✨ Service discovery enabled!
# No more hardcoded IPs! 🎉
```

**DAPR ACTIVATED** 🎭

---

### **🎮 LEVEL 5: Migrate to Azure Services**

```bash
# Switch to Azure services step
git checkout step-4-azure-services

# ☁️ Deploy Azure infrastructure
az login
az group create --name pawscare-rg --location eastus

# 🏗️ Deploy with Bicep
gh copilot suggest "deploy azure cosmos db, service bus, and blob storage using bicep"

# Example:
az deployment group create \
  --resource-group pawscare-rg \
  --template-file azure-infrastructure/main.bicep

# 📊 Update app configs to use Azure services
# MongoDB → Cosmos DB (MongoDB API)
# RabbitMQ → Service Bus
# SMB → Blob Storage
```

**AZURE SERVICES DEPLOYED** ☁️

---

### **🎮 LEVEL 6: Deploy to Container Apps**

```bash
# Switch to Container Apps deployment step
git checkout step-5-container-apps-deploy

# 📦 Create Azure Container Registry
az acr create --name pawscareacr --resource-group pawscare-rg --sku Standard

# 🐳 Push images to ACR
gh copilot suggest "tag and push all docker images to azure container registry"

# IMAGE PUSHED 🐳 web-frontend
# IMAGE PUSHED 🐳 api-server
# IMAGE PUSHED 🐳 background-worker

# 🚀 Deploy Container Apps environment
az containerapp env create \
  --name pawscare-env \
  --resource-group pawscare-rg \
  --location eastus

# 📦 Create the container apps
gh copilot suggest "deploy three container apps from ACR images"

# CONTAINER APP DEPLOYED 🚀 web-frontend
# CONTAINER APP DEPLOYED 🚀 api-server
# CONTAINER APP DEPLOYED 🚀 background-worker
```

**CONTAINER APPS LIVE** 🎉

---

### **🎮 LEVEL 7: Configure Auto-Scaling**

```bash
# ⚡ Set up KEDA scaling rules
gh copilot suggest "configure http scaling for web frontend and queue-based scaling for worker"

# Example KEDA rules:
# - Web Frontend: Scale 1-10 based on HTTP requests
# - API Server: Scale 1-5 based on concurrent requests
# - Background Worker: Scale 0-3 based on Service Bus queue depth

# 🧪 Test auto-scaling
# Generate load and watch pods scale up!
hey -z 60s -c 50 https://web-frontend.azurecontainerapps.io
```

**SCALING UP** ⬆️

---

### **🎮 LEVEL 8: Validate End-to-End**

```bash
# 🧪 Run the comprehensive E2E validation suite
# PowerShell:
.\scripts\validate-e2e.ps1

# Bash:
./scripts/validate-e2e.sh

# With Dapr sidecars running:
.\scripts\validate-e2e.ps1 -DaprMode
./scripts/validate-e2e.sh --dapr-mode

# The E2E suite validates:
# ✅ Health check all 3 services (API, Web, Worker)
# ✅ Create a pet patient via API
# ✅ Book an appointment (triggers pub/sub message)
# ✅ Upload a lab result (simulated blob storage flow)
# ✅ Verify background worker processes messages
# ✅ Check Dapr sidecar health
# ✅ Validate Azure Blob Storage integration (config + Bicep)
# ✅ Docker container health status

# 🏆 ACHIEVEMENT UNLOCKED: VM-to-Container Migration Master!
```

**QUEST COMPLETE** 🏆

---

## ⏱️ DURATION

**Estimated Time:** 4-6 hours ⏰

- ⚙️ Legacy System Exploration: 30 mins
- 🐳 Containerization: 1 hour
- 🧪 Local Testing: 30 mins
- 🎭 Dapr Integration: 1 hour
- ☁️ Azure Services Migration: 1 hour
- 🚀 Container Apps Deployment: 1 hour
- ⚡ Auto-Scaling Configuration: 30 mins
- ✅ End-to-End Validation: 30 mins

**Pro Tip:** Take breaks! Hydrate! 💧 This is a marathon, not a sprint! 🏃‍♀️

---

## 📚 RESOURCES

### **Documentation** 📖

- 🌐 [Azure Container Apps Docs](https://learn.microsoft.com/azure/container-apps/)
- 🎭 [Dapr Documentation](https://docs.dapr.io/)
- 📦 [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- ⚡ [KEDA Scaling](https://keda.sh/)
- 🐳 [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)

### **Architecture Patterns** 🏗️

- 📊 [Microservices Architecture](https://learn.microsoft.com/azure/architecture/guide/architecture-styles/microservices)
- 🎯 [Strangler Fig Pattern](https://learn.microsoft.com/azure/architecture/patterns/strangler-fig)
- 🔄 [Sidecar Pattern (Dapr)](https://learn.microsoft.com/azure/architecture/patterns/sidecar)

### **Tools You'll Use** 🛠️

- 🐳 Docker Desktop
- ☁️ Azure CLI
- 🎭 Dapr CLI
- 🤖 GitHub Copilot CLI
- 📦 Azure Container Apps CLI

### **Sample Code & Templates** 💻

- 🌟 [.NET Dockerfile Best Practices](https://docs.docker.com/samples/dotnetcore/)
- 🟢 [Node.js Dockerfile Best Practices](https://docs.docker.com/samples/nodejs/)
- 🐍 [Python Dockerfile Best Practices](https://docs.docker.com/samples/python/)
- 🏗️ [Bicep Templates for Container Apps](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)

---

## 🎊 WHAT'S NEXT?

**You've mastered VM-to-Container migration!** Now what? 🚀

### **Level Up Your Skills:**

1. 🔄 **Add CI/CD:** Set up GitHub Actions for automated deployments
2. 🛡️ **Implement Security:** Add Azure Key Vault for secrets management
3. 📊 **Advanced Monitoring:** Integrate Application Insights and custom metrics
4. 🌍 **Multi-Region Deployment:** Deploy to multiple Azure regions for HA
5. 🧪 **Chaos Engineering:** Test resilience with Azure Chaos Studio

### **Explore More Labs:**

- 🌐 **Monolith to Microservices** (if available)
- 🔄 **CI/CD with GitHub Actions**
- 🛡️ **Zero Trust Security**
- 📊 **Observability with OpenTelemetry**

---

## 📊 DOCUMENTATION REFERENCE

| Document | Description |
|----------|-------------|
| [`APPMODLAB.md`](APPMODLAB.md) | Full lab walkthrough with step-by-step instructions |
| [`QUICKSTART.md`](QUICKSTART.md) | Quick-start guide to get running fast |
| [`assets/architecture-after.md`](assets/architecture-after.md) | Modernized architecture: Container Apps topology, Dapr components, KEDA scaling, network flows |
| [`assets/migration-checklist.md`](assets/migration-checklist.md) | 50-item checklist comparing legacy vs modernized for every concern |
| [`assets/legacy-assessment.md`](assets/legacy-assessment.md) | Analysis of the legacy VM-based system |
| [`assets/scaling-config.md`](assets/scaling-config.md) | KEDA auto-scaling rules and configuration |

### **Scripts Reference** 🛠️

| Script | Description |
|--------|-------------|
| `scripts/deploy-azure.ps1` / `.sh` | Deploy full Azure infrastructure + Container Apps |
| `scripts/test-local.ps1` / `.sh` | Smoke test local Docker Compose services |
| `scripts/validate-e2e.ps1` / `.sh` | Comprehensive E2E validation of the modernized system |
| `scripts/load-test.ps1` / `.sh` | Generate load to verify KEDA auto-scaling |

### **Infrastructure Files** ☁️

| File | Resources |
|------|-----------|
| `infrastructure/main.bicep` | Log Analytics, Container Registry, Container Apps Environment |
| `infrastructure/deploy.bicep` | 3 Container Apps with Dapr, KEDA scaling rules, env vars |
| `infrastructure/azure-services.bicep` | Cosmos DB, Service Bus, Blob Storage, Azure SQL |

---

## 🎮 GAME OVER? NEVER!

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🏆 CONGRATULATIONS, CLOUD ARCHITECT! 🏆                    ║
║                                                              ║
║   You've successfully transformed static VMs into            ║
║   a modern, auto-scaling, serverless container platform!    ║
║                                                              ║
║   📊 STATS:                                                  ║
║   ✅ 3 VMs containerized                                     ║
║   ✅ 3 Docker images built                                   ║
║   ✅ Dapr sidecars configured                                ║
║   ✅ Azure services integrated                               ║
║   ✅ Auto-scaling enabled                                    ║
║   ✅ 100% serverless achievement unlocked                    ║
║                                                              ║
║   🚀 Your infrastructure is now CLOUD NATIVE! 🚀            ║
║                                                              ║
║   Press START to deploy to production! 🎮                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🙏 CREDITS

**Built with 💜 by the AppMod GBB Team**

- 🎨 Retro aesthetic by Dana, the Technical Writer
- 💻 Lab content by the Squad
- 🚀 Powered by Azure Container Apps
- 🎭 Enhanced by Dapr
- 🤖 Assisted by GitHub Copilot

---

## 📞 NEED HELP?

- 💬 **Issues?** [Open a GitHub Issue](https://github.com/EmeaAppGbb/appmodlab-on-prem-vms-to-container-apps/issues)
- 📧 **Questions?** Reach out to the AppMod GBB team
- 📚 **Docs:** Check `APPMODLAB.md` for detailed instructions

---

**🌟 Happy Containerizing! May your pods always be healthy and your scaling infinite! 🌟**

```
     _____                _          _                                               _   
    / ____|              | |        (_)                                             | |  
   | |     ___  _ __   __| |_   _    _ ___   __ _ _ __ ___   ___   ___  ___   ___  | |  
   | |    / _ \| '_ \ / _` | | | |  | / __| / _` | '__/ _ \ / _ \ / __|/ _ \ / _ \ | |  
   | |___| (_) | | | | (_| | |_| |  | \__ \| (_| | | |  __/| (_) |\__ \ (_) | (_) ||_|  
    \_____\___/|_| |_|\__,_|\__, |  |_|___/ \__,_|_|  \___| \___/ |___/\___/ \___/ (_)  
                             __/ |_____                                                  
                            |___/______|                                                 
```

**🐳 FROM VMs TO CONTAINERS — THE FUTURE IS NOW! 🚀**
