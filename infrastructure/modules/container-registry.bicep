@description('Azure region for the Container Registry')
param location string

@description('Name of the Container Registry')
param name string

@description('SKU for the Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

@description('Container Registry login server')
output loginServer string = acr.properties.loginServer

@description('Container Registry name')
output name string = acr.name

@description('Container Registry resource ID')
output id string = acr.id

@description('Container Registry admin username')
#disable-next-line outputs-should-not-contain-secrets
output adminUsername string = acr.listCredentials().username

@description('Container Registry admin password')
#disable-next-line outputs-should-not-contain-secrets
output adminPassword string = acr.listCredentials().passwords[0].value
