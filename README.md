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
├── 📜 README.md                    ← You are here! 🌟
├── 📘 APPMODLAB.md                 ← Full lab walkthrough
├── 🏥 pawscare-system/
│   ├── 🌐 web-frontend/            ← ASP.NET Core MVC (VM 1)
│   │   ├── PawsCare.Web.csproj
│   │   ├── Controllers/
│   │   ├── Views/
│   │   ├── appsettings.json        ← Hardcoded IPs (gasp!)
│   │   └── Dockerfile              ← Multi-stage .NET build
│   ├── 🔌 api-server/              ← Node.js Express (VM 2)
│   │   ├── package.json
│   │   ├── server.js
│   │   ├── routes/
│   │   ├── models/
│   │   └── Dockerfile              ← Optimized Node.js image
│   ├── ⚙️ background-worker/       ← Python Celery (VM 3)
│   │   ├── requirements.txt
│   │   ├── worker.py
│   │   ├── tasks/
│   │   └── Dockerfile              ← Python multi-stage build
│   └── 🏗️ infrastructure/
│       ├── network-diagram.png     ← The "before" topology
│       └── vm-setup-scripts/       ← Legacy VM provisioning
├── 🎭 dapr-config/
│   ├── pubsub.yaml                 ← Service Bus configuration
│   ├── statestore.yaml             ← Cosmos DB state management
│   └── components/
├── ☁️ azure-infrastructure/
│   ├── main.bicep                  ← Infrastructure as Code
│   ├── container-apps.bicep
│   ├── cosmos-db.bicep
│   ├── service-bus.bicep
│   └── blob-storage.bicep
├── 🔄 .github/workflows/
│   └── deploy.yml                  ← CI/CD magic
├── 🐳 docker-compose.yml           ← Local VM simulation
└── 📊 architecture/
    ├── before.png                  ← VM topology
    └── after.png                   ← Container Apps architecture
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
# 🎉 Test the full system
# 1. Book an appointment via the web UI
# 2. Upload a lab result (triggers background processing)
# 3. Verify appointment reminder email sent
# 4. Check Azure Monitor for logs and metrics

# 🔍 Query logs with Copilot CLI
gh copilot suggest "query container app logs for the last hour"

# ✅ Verify Dapr telemetry
# ✅ Check Service Bus message flow
# ✅ Confirm Blob Storage uploads

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
