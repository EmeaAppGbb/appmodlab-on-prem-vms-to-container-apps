@description('Azure region for the Container Apps Environment')
param location string

@description('Name of the Container Apps Environment')
param name string

@description('Log Analytics workspace shared key')
@secure()
param logAnalyticsSharedKey string

@description('Log Analytics workspace customer ID')
param logAnalyticsCustomerId string

@description('Enable Dapr configuration')
param daprEnabled bool = true

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
    daprAIConnectionString: ''
    zoneRedundant: false
  }
}

// Dapr state store component (Azure Cosmos DB)
resource daprStateStore 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = if (daprEnabled) {
  parent: containerAppsEnv
  name: 'statestore'
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    metadata: [
      { name: 'url', value: '' }
      { name: 'masterKey', value: '' }
      { name: 'database', value: 'pawscare-state' }
      { name: 'collection', value: 'state' }
      { name: 'actorStateStore', value: 'true' }
    ]
    scopes: [
      'api-server'
      'background-worker'
      'web-frontend'
    ]
  }
}

// Dapr pub/sub component (Azure Service Bus)
resource daprPubSub 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = if (daprEnabled) {
  parent: containerAppsEnv
  name: 'pubsub'
  properties: {
    componentType: 'pubsub.azure.servicebus.topics'
    version: 'v1'
    metadata: [
      { name: 'connectionString', value: '' }
      { name: 'maxDeliveryCount', value: '10' }
      { name: 'lockDurationInSec', value: '30' }
      { name: 'defaultMessageTimeToLiveInSec', value: '86400' }
      { name: 'maxConcurrentHandlers', value: '10' }
    ]
    scopes: [
      'api-server'
      'background-worker'
    ]
  }
}

// Dapr blob storage binding
resource daprBlobStore 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = if (daprEnabled) {
  parent: containerAppsEnv
  name: 'blobstore'
  properties: {
    componentType: 'bindings.azure.blobstorage'
    version: 'v1'
    metadata: [
      { name: 'accountName', value: '' }
      { name: 'accountKey', value: '' }
      { name: 'containerName', value: 'documents' }
      { name: 'decodeBase64', value: 'true' }
    ]
    scopes: [
      'background-worker'
    ]
  }
}

@description('Container Apps Environment ID')
output id string = containerAppsEnv.id

@description('Container Apps Environment name')
output name string = containerAppsEnv.name

@description('Container Apps Environment default domain')
output defaultDomain string = containerAppsEnv.properties.defaultDomain

@description('Container Apps Environment static IP')
output staticIp string = containerAppsEnv.properties.staticIp
