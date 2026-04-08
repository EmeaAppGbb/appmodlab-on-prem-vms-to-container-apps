# PawsCare Veterinary Network - VM Infrastructure

## Legacy Three-VM Architecture

This document describes the legacy on-premises VM infrastructure for the PawsCare Veterinary Network system.

### VM Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network: 10.0.1.0/24             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  │   VM 1           │  │   VM 2           │  │   VM 3           │
│  │   10.0.1.10      │  │   10.0.1.20      │  │   10.0.1.30      │
│  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
│  │ Windows Server   │  │ Ubuntu 20.04     │  │ Ubuntu 20.04     │
│  │ 2019             │  │                  │  │                  │
│  │                  │  │ Node.js 14.x     │  │ Python 3.8       │
│  │ IIS 10           │  │ Express 4.x      │  │ Celery Worker    │
│  │ ASP.NET Core 3.1 │  │ MongoDB 4.4      │  │ RabbitMQ 3.8     │
│  │ SQL Server 2019  │  │                  │  │                  │
│  │                  │  │                  │  │                  │
│  │ 4 vCPU, 8GB RAM  │  │ 2 vCPU, 4GB RAM  │  │ 2 vCPU, 4GB RAM  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘
│         │                      │                      │
│         │                      │                      │
│  ┌──────┴──────────────────────┴──────────────────────┴─────┐
│  │              SMB Share: \\10.0.1.10\documents             │
│  │           (Lab results, X-rays, reports)                 │
│  └──────────────────────────────────────────────────────────┘
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### VM Specifications

#### VM 1: Web Frontend + Database (10.0.1.10)
- **OS**: Windows Server 2019 Standard
- **CPU**: 4 vCPU
- **Memory**: 8 GB RAM
- **Storage**: 100 GB SSD
- **Software**:
  - IIS 10.0
  - ASP.NET Core 3.1 Runtime
  - SQL Server 2019 Standard Edition
  - .NET Core 3.1 SDK
- **Ports**:
  - 80 (HTTP)
  - 443 (HTTPS)
  - 1433 (SQL Server)
  - 445 (SMB)

#### VM 2: API Server + NoSQL Database (10.0.1.20)
- **OS**: Ubuntu 20.04 LTS
- **CPU**: 2 vCPU
- **Memory**: 4 GB RAM
- **Storage**: 50 GB SSD
- **Software**:
  - Node.js 14.x
  - npm 6.x
  - MongoDB 4.4
  - PM2 process manager
- **Ports**:
  - 3000 (API)
  - 27017 (MongoDB)

#### VM 3: Background Worker + Message Queue (10.0.1.30)
- **OS**: Ubuntu 20.04 LTS
- **CPU**: 2 vCPU
- **Memory**: 4 GB RAM
- **Storage**: 50 GB SSD
- **Software**:
  - Python 3.8
  - pip3
  - RabbitMQ 3.8
  - Celery 5.x
- **Ports**:
  - 5672 (RabbitMQ)
  - 15672 (RabbitMQ Management UI)

### Network Security Groups (NSG)

#### Inbound Rules
| Priority | Source | Destination | Port | Protocol | Description |
|----------|--------|-------------|------|----------|-------------|
| 100 | Internet | VM1:80 | 80 | TCP | HTTP traffic |
| 110 | Internet | VM1:443 | 443 | TCP | HTTPS traffic |
| 200 | VM1 | VM2:3000 | 3000 | TCP | API calls |
| 210 | VM2 | VM3:5672 | 5672 | TCP | RabbitMQ |
| 300 | Internal | VM1:445 | 445 | TCP | SMB file share |
| 400 | Internal | All | 22/3389 | TCP | Management access |

#### Outbound Rules
- Allow all outbound traffic (default)

### Storage Configuration

#### SMB File Share
- **Path**: `\\10.0.1.10\documents`
- **Purpose**: Shared storage for lab results, X-ray images, reports
- **Structure**:
  ```
  \\10.0.1.10\documents\
  ├── lab-results\
  ├── xrays\
  ├── prescriptions\
  └── reports\
  ```
- **Permissions**: Authenticated users (read/write)
- **Backup**: Daily full backup at 2:00 AM

### Application Configuration

#### Hardcoded IP Dependencies
All applications use hardcoded IP addresses for service discovery:

**Web Frontend (VM1)**:
- API Server: `http://10.0.1.20:3000`
- SQL Server: `localhost:1433`
- SMB Share: `\\10.0.1.10\documents`

**API Server (VM2)**:
- MongoDB: `localhost:27017`
- RabbitMQ: `amqp://10.0.1.30:5672`
- Web Frontend: `http://10.0.1.10`

**Background Worker (VM3)**:
- RabbitMQ: `localhost:5672`
- API Server: `http://10.0.1.20:3000`
- SMB Share: `\\10.0.1.10\documents`

### Maintenance Windows

- **Patching**: Second Tuesday of each month, 2:00 AM - 6:00 AM PST
- **Downtime**: Typically 30-45 minutes per VM
- **Process**:
  1. Stop background worker (VM3)
  2. Stop API server (VM2)
  3. Stop web frontend (VM1)
  4. Apply OS patches
  5. Restart VMs in reverse order
  6. Verify connectivity

### Backup Strategy

#### Database Backups
- **SQL Server**: Full backup nightly at 1:00 AM, transaction logs every hour
- **MongoDB**: Full backup nightly at 1:30 AM, oplog continuously

#### File Share Backups
- **SMB Share**: Full backup nightly at 2:00 AM
- **Retention**: 30 days

#### VM Snapshots
- Weekly snapshots before patching
- Retention: 4 weeks

### Monitoring

#### Windows Server (VM1)
- CPU, Memory, Disk via Windows Performance Monitor
- IIS logs in `C:\inetpub\logs`
- SQL Server logs in `C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Log`

#### Ubuntu Servers (VM2, VM3)
- System metrics via `top`, `htop`
- Application logs in `/var/log`
- MongoDB logs: `/var/log/mongodb/mongod.log`
- RabbitMQ logs: `/var/log/rabbitmq/rabbit@hostname.log`

### Known Issues and Limitations

1. **No auto-scaling**: VMs are sized for peak load, wasting resources during off-hours
2. **Manual patching**: Requires scheduled downtime
3. **Single points of failure**: No redundancy for any component
4. **Hardcoded IPs**: Makes infrastructure changes difficult
5. **No health checks**: Must manually verify services after restarts
6. **SMB dependency**: File share is single point of failure
7. **No container orchestration**: Cannot easily scale or deploy updates
8. **SSL certificate management**: Manual renewal and deployment on IIS
9. **No service discovery**: Services must know exact IP addresses
10. **Limited observability**: Logs scattered across VMs, no centralized monitoring

### Cost Analysis

Monthly costs (estimated):
- VM1 (4 vCPU, 8GB): $150
- VM2 (2 vCPU, 4GB): $75
- VM3 (2 vCPU, 4GB): $75
- Storage (200GB SSD): $40
- Backup storage: $30
- **Total**: ~$370/month (always running, regardless of load)

### Migration Notes

When migrating to Azure Container Apps:
1. Replace hardcoded IPs with Dapr service invocation
2. Replace RabbitMQ with Azure Service Bus
3. Replace SMB share with Azure Blob Storage
4. Replace SQL Server with Azure SQL Database
5. Replace MongoDB with Azure Cosmos DB (MongoDB API)
6. Implement KEDA auto-scaling rules
7. Use managed certificates for TLS
8. Enable Azure Monitor for observability
