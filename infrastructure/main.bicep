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

// --- Outputs ---
@description('Container Registry login server')
output acrLoginServer string = acr.outputs.loginServer

@description('Container Registry name')
output acrName string = acr.outputs.name

@description('Container Apps Environment ID')
output containerAppsEnvId string = containerAppsEnv.outputs.id

@description('Container Apps Environment default domain')
output containerAppsEnvDomain string = containerAppsEnv.outputs.defaultDomain

@description('Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.id
