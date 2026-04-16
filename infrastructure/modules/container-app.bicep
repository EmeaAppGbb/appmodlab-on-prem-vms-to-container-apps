@description('Azure region for the Container App')
param location string

@description('Name of the Container App')
param name string

@description('Container Apps Environment ID')
param containerAppsEnvId string

@description('Container image to deploy')
param containerImage string

@description('Container port to expose')
param targetPort int

@description('Enable external ingress')
param externalIngress bool = false

@description('Dapr app ID')
param daprAppId string

@description('Dapr app port')
param daprAppPort int

@description('Enable Dapr sidecar')
param daprEnabled bool = true

@description('Environment variables for the container')
param envVars array = []

@description('CPU cores allocated to the container (e.g., 0.5)')
param cpuCores string = '0.5'

@description('Memory allocated to the container (e.g., 1Gi)')
param memory string = '1Gi'

@description('Minimum number of replicas')
param minReplicas int = 0

@description('Maximum number of replicas')
param maxReplicas int = 3

@description('KEDA scaling rules for the Container App')
param scalingRules array = []

@description('Container registry server')
param registryServer string = ''

@description('Container registry username')
param registryUsername string = ''

@description('Container registry password')
@secure()
param registryPassword string = ''

var registryConfig = !empty(registryServer) ? [
  {
    server: registryServer
    username: registryUsername
    passwordSecretRef: 'registry-password'
  }
] : []

var secrets = !empty(registryPassword) ? [
  {
    name: 'registry-password'
    value: registryPassword
  }
] : []

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: externalIngress
        targetPort: targetPort
        transport: 'auto'
        allowInsecure: false
      }
      dapr: {
        enabled: daprEnabled
        appId: daprAppId
        appPort: daprAppPort
        appProtocol: 'http'
      }
      secrets: secrets
      registries: registryConfig
    }
    template: {
      containers: [
        {
          name: name
          image: containerImage
          resources: {
            cpu: json(cpuCores)
            memory: memory
          }
          env: envVars
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: targetPort
              }
              initialDelaySeconds: 15
              periodSeconds: 30
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health'
                port: targetPort
              }
              initialDelaySeconds: 5
              periodSeconds: 10
              failureThreshold: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: empty(scalingRules) ? null : scalingRules
      }
    }
  }
}

@description('Container App FQDN')
output fqdn string = containerApp.properties.configuration.ingress.fqdn

@description('Container App URL')
output url string = 'https://${containerApp.properties.configuration.ingress.fqdn}'

@description('Container App name')
output name string = containerApp.name

@description('Container App resource ID')
output id string = containerApp.id
