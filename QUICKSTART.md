# Quick Start Guide - PawsCare Legacy VM System

## Running the Legacy System with Docker Compose

This guide shows how to run the three-VM legacy system locally using Docker Compose.

### Prerequisites

- Docker Desktop installed and running
- At least 8GB of available RAM
- 10GB of free disk space

### Steps

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd appmodlab-on-prem-vms-to-container-apps
   ```

2. **Start all three VMs** (simulated as containers):
   ```bash
   docker-compose up -d
   ```

   This will start:
   - VM 1: Web Frontend (ASP.NET Core) on port 5000
   - VM 2: API Server (Node.js) on port 3000
   - VM 3: Background Worker (Python + RabbitMQ)

3. **Check the status**:
   ```bash
   docker-compose ps
   ```

4. **View logs**:
   ```bash
   # All services
   docker-compose logs -f

   # Specific service
   docker-compose logs -f web-frontend
   docker-compose logs -f api-server
   docker-compose logs -f background-worker
   ```

5. **Access the applications**:
   - Web Frontend: http://localhost:5000
   - API Server: http://localhost:3000
   - API Health Check: http://localhost:3000/health
   - RabbitMQ Management: http://localhost:15672 (guest/guest)

### Testing the System

1. **View the Dashboard**:
   - Open http://localhost:5000 in your browser
   - You should see statistics for patients, owners, and appointments

2. **List Patients**:
   - Navigate to "Patients" in the menu
   - You should see a list of pre-seeded pets

3. **View Appointments**:
   - Navigate to "Appointments" in the menu
   - You should see scheduled appointments

4. **Test API Directly**:
   ```bash
   # Get all patients
   curl http://localhost:3000/api/patients

   # Get all appointments
   curl http://localhost:3000/api/appointments

   # Health check
   curl http://localhost:3000/health
   ```

5. **Test Background Worker**:
   - Create a new appointment through the web UI
   - Check the background-worker logs to see the reminder being processed:
     ```bash
     docker-compose logs background-worker
     ```

### Stopping the System

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (clears all data)
docker-compose down -v
```

### Troubleshooting

**Web frontend can't connect to API**:
- Check if API server is running: `docker-compose ps api-server`
- Check API logs: `docker-compose logs api-server`
- Verify network: `docker network inspect appmodlab-on-prem-vms-to-container-apps_vm_network`

**MongoDB connection errors**:
- MongoDB takes 30-60 seconds to start up fully
- Wait a bit longer and refresh the page
- Check logs: `docker-compose logs api-server`

**RabbitMQ not receiving messages**:
- Check if worker is running: `docker-compose ps background-worker`
- Check RabbitMQ status: http://localhost:15672
- View worker logs: `docker-compose logs background-worker`

### Understanding the Legacy Anti-Patterns

As you use the system, notice these legacy VM anti-patterns:

1. **Hardcoded IP Addresses**: Check `appsettings.json` and `server.js` for `10.0.1.x` references
2. **No Auto-Scaling**: All three VMs run continuously regardless of load
3. **No Health Checks**: Services don't expose health endpoints (except API /health)
4. **SMB File Share**: Documents are stored in a shared volume mount
5. **Single Point of Failure**: No redundancy for any component
6. **Manual SSL**: In production, SSL certificates would need manual deployment
7. **Cron-based Scheduling**: Background tasks use cron instead of modern schedulers

These are exactly the problems that containerization with Azure Container Apps solves!

### Next Steps

After exploring the legacy system:
1. Review the architecture diagram in `infrastructure/README.md`
2. Understand the dependencies between VMs
3. Think about how you would modernize this to containers
4. Proceed to the lab instructions for containerization
