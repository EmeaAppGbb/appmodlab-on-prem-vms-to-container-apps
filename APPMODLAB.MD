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
