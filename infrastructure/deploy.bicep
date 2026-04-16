@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Base name for all resources')
param baseName string = 'pawscare'

@description('SKU for the Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string = 'Basic'

@description('Container image tag')
param imageTag string = 'latest'

// --- Variables ---
var uniqueSuffix = uniqueString(resourceGroup().id)
var acrName = '${baseName}acr${uniqueSuffix}'
var containerAppsEnvName = '${baseName}-env-${environment}'
var logAnalyticsName = '${baseName}-logs-${uniqueSuffix}'

// --- Log Analytics Workspace ---
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// --- Container Registry ---
module acr 'modules/container-registry.bicep' = {
  name: 'acr-deployment'
  params: {
    location: location
    name: acrName
    sku: acrSku
  }
}

// --- Container Apps Environment ---
module containerAppsEnv 'modules/container-apps-env.bicep' = {
  name: 'container-apps-env-deployment'
  params: {
    location: location
    name: containerAppsEnvName
    logAnalyticsCustomerId: logAnalytics.properties.customerId
    logAnalyticsSharedKey: logAnalytics.listKeys().primarySharedKey
    daprEnabled: true
  }
}

// --- Container Apps ---

// Web Frontend (ASP.NET Core - port 8080)
module webFrontend 'modules/container-app.bicep' = {
  name: 'web-frontend-deployment'
  params: {
    location: location
    name: '${baseName}-web-frontend'
    containerAppsEnvId: containerAppsEnv.outputs.id
    containerImage: '${acr.outputs.loginServer}/pawscare/web-frontend:${imageTag}'
    targetPort: 8080
    externalIngress: true
    daprAppId: 'web-frontend'
    daprAppPort: 8080
    registryServer: acr.outputs.loginServer
    registryUsername: acr.outputs.adminUsername
    registryPassword: acr.outputs.adminPassword
    cpuCores: '0.5'
    memory: '1Gi'
    minReplicas: 1
    maxReplicas: 3
    envVars: [
      { name: 'ASPNETCORE_URLS', value: 'http://+:8080' }
      { name: 'ASPNETCORE_ENVIRONMENT', value: environment == 'prod' ? 'Production' : 'Development' }
      { name: 'Dapr__HttpPort', value: '3500' }
      { name: 'Dapr__ApiServerAppId', value: 'api-server' }
    ]
  }
}

// API Server (Node.js - port 3000)
module apiServer 'modules/container-app.bicep' = {
  name: 'api-server-deployment'
  params: {
    location: location
    name: '${baseName}-api-server'
    containerAppsEnvId: containerAppsEnv.outputs.id
    containerImage: '${acr.outputs.loginServer}/pawscare/api-server:${imageTag}'
    targetPort: 3000
    externalIngress: false
    daprAppId: 'api-server'
    daprAppPort: 3000
    registryServer: acr.outputs.loginServer
    registryUsername: acr.outputs.adminUsername
    registryPassword: acr.outputs.adminPassword
    cpuCores: '0.5'
    memory: '1Gi'
    minReplicas: 1
    maxReplicas: 5
    envVars: [
      { name: 'DAPR_HTTP_PORT', value: '3500' }
    ]
  }
}

// Background Worker (Python - port 8080)
module backgroundWorker 'modules/container-app.bicep' = {
  name: 'background-worker-deployment'
  params: {
    location: location
    name: '${baseName}-background-worker'
    containerAppsEnvId: containerAppsEnv.outputs.id
    containerImage: '${acr.outputs.loginServer}/pawscare/background-worker:${imageTag}'
    targetPort: 8080
    externalIngress: false
    daprAppId: 'background-worker'
    daprAppPort: 8080
    registryServer: acr.outputs.loginServer
    registryUsername: acr.outputs.adminUsername
    registryPassword: acr.outputs.adminPassword
    cpuCores: '0.25'
    memory: '0.5Gi'
    minReplicas: 1
    maxReplicas: 3
    envVars: [
      { name: 'DAPR_HTTP_PORT', value: '3500' }
      { name: 'APP_PORT', value: '8080' }
    ]
  }
}

// --- Outputs ---
@description('Container Registry login server')
output acrLoginServer string = acr.outputs.loginServer

@description('Web Frontend URL')
output webFrontendUrl string = webFrontend.outputs.url

@description('API Server FQDN (internal)')
output apiServerFqdn string = apiServer.outputs.fqdn

@description('Background Worker name')
output backgroundWorkerName string = backgroundWorker.outputs.name

@description('Container Apps Environment default domain')
output containerAppsEnvDomain string = containerAppsEnv.outputs.defaultDomain
