# PawsCare Veterinary Network - Legacy VM System

## 🎯 Purpose

This is a **demo legacy application** for the "On-Premises VMs to Azure Container Apps" lab. It simulates a typical three-tier VM-based system with all the common anti-patterns found in legacy infrastructure.

## 📋 What's Included

This repository contains a complete three-tier veterinary clinic management system running on three separate VMs:

### VM 1: Web Frontend (Windows Server 2019)
- **Technology**: ASP.NET Core 3.1 MVC + SQL Server 2019
- **IP**: 10.0.1.10
- **Components**:
  - IIS 10 web server
  - ASP.NET Core MVC web application
  - SQL Server for owner and vet staff data
  - SMB file share for documents

### VM 2: API Server (Ubuntu 20.04)
- **Technology**: Node.js 14.x + Express + MongoDB 4.4
- **IP**: 10.0.1.20
- **Components**:
  - RESTful API for patients, appointments, prescriptions, lab results
  - MongoDB for NoSQL storage
  - RabbitMQ client for message publishing

### VM 3: Background Worker (Ubuntu 20.04)
- **Technology**: Python 3.8 + Celery + RabbitMQ 3.8
- **IP**: 10.0.1.30
- **Components**:
  - RabbitMQ message broker
  - Celery background workers
  - Cron-based scheduled tasks
  - Email reminder service
  - Lab result processing

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repo-url>
cd appmodlab-on-prem-vms-to-container-apps

# Start all three VMs (simulated as Docker containers)
docker-compose up -d

# Access the application
# Web UI: http://localhost:5000
# API: http://localhost:3000
# RabbitMQ Management: http://localhost:15672 (guest/guest)

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

For detailed instructions, see [QUICKSTART.md](QUICKSTART.md).

## 🏗️ Architecture

```
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│   VM 1         │      │   VM 2         │      │   VM 3         │
│   Web Frontend │─────▶│   API Server   │◀─────│  Worker        │
│   + SQL Server │      │   + MongoDB    │      │  + RabbitMQ    │
│   10.0.1.10    │      │   10.0.1.20    │      │  10.0.1.30     │
└────────────────┘      └────────────────┘      └────────────────┘
         │                      │                      │
         └──────────────────────┴──────────────────────┘
                       SMB File Share
                    \\10.0.1.10\documents
```

See [infrastructure/README.md](infrastructure/README.md) for detailed architecture documentation.

## 📚 Features

- ✅ Pet patient management
- ✅ Appointment scheduling
- ✅ Prescription tracking
- ✅ Lab result uploads
- ✅ Automated appointment reminders
- ✅ Background report generation
- ✅ Owner and veterinarian records

## ⚠️ Legacy Anti-Patterns (By Design)

This application intentionally demonstrates common legacy VM anti-patterns:

1. **Hardcoded IP Addresses** - Services reference each other via static IPs
2. **No Auto-Scaling** - Fixed VM sizes regardless of load
3. **Manual Patching** - Requires scheduled downtime for updates
4. **SMB File Share** - Centralized file storage with single point of failure
5. **No Health Checks** - Services don't expose health endpoints
6. **Cron-based Scheduling** - Background tasks use cron instead of orchestration
7. **No Service Discovery** - Must know exact IP addresses
8. **Manual SSL Management** - Certificates deployed manually to IIS
9. **Single Instances** - No redundancy or high availability
10. **Scattered Logs** - Each VM has its own logs, no centralization

These are the exact problems that containerization with Azure Container Apps solves!

## 🎓 Learning Objectives

By exploring this legacy system and migrating it to Azure Container Apps, you'll learn:

- How to assess VM-based applications for containerization
- Creating optimized multi-stage Dockerfiles for .NET, Node.js, and Python
- Using Dapr for service discovery and pub/sub messaging
- Replacing infrastructure dependencies (RabbitMQ → Service Bus, SMB → Blob Storage)
- Configuring KEDA auto-scaling rules
- Deploying multi-container applications to Azure Container Apps
- Modernizing legacy anti-patterns with cloud-native patterns

## 📖 Lab Exercises

This repository is the starting point for the lab. The lab will guide you through:

1. **Analyzing the Legacy System** - Understanding the three-tier architecture
2. **Creating Dockerfiles** - Containerizing each service
3. **Local Container Testing** - Running with Docker Compose
4. **Adding Dapr** - Service-to-service communication
5. **Azure Service Integration** - Cosmos DB, Service Bus, Blob Storage
6. **Deploying to Container Apps** - Full Azure deployment
7. **Configuring Auto-Scaling** - KEDA rules for dynamic scaling

## 🛠️ Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Web Frontend | ASP.NET Core | 3.1 |
| API Server | Node.js + Express | 14.x |
| Background Worker | Python + Celery | 3.8 |
| Relational DB | SQL Server | 2019 |
| NoSQL DB | MongoDB | 4.4 |
| Message Queue | RabbitMQ | 3.8 |
| File Storage | SMB Share | N/A |

## 📁 Repository Structure

```
appmodlab-on-prem-vms-to-container-apps/
├── web-frontend/           # ASP.NET Core MVC application
│   ├── Controllers/
│   ├── Views/
│   ├── Models/
│   └── Dockerfile.legacy
├── api-server/             # Node.js Express API
│   ├── routes/
│   ├── models/
│   └── Dockerfile.legacy
├── background-worker/      # Python Celery worker
│   ├── tasks/
│   └── Dockerfile.legacy
├── infrastructure/         # VM setup and documentation
│   └── vm-setup-scripts/
├── docker-compose.yml      # Simulates the 3-VM topology
├── QUICKSTART.md          # Quick start guide
└── README.md              # This file
```

## 🤝 Contributing

This is a lab template. For issues or improvements, please open an issue or pull request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Related Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Dapr Documentation](https://docs.dapr.io/)
- [KEDA Documentation](https://keda.sh/)
- [Container Apps Best Practices](https://docs.microsoft.com/azure/container-apps/best-practices)

---

**Note**: This is a demo application for training purposes. The "legacy" anti-patterns are intentional to demonstrate real-world migration scenarios.
