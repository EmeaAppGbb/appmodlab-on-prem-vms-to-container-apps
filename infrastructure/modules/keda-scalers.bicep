@description('Service Bus connection string for KEDA queue-based scaling')
@secure()
param serviceBusConnectionString string = ''

@description('Service Bus queue name to monitor for scaling')
param queueName string = 'background-tasks'

@description('Message count threshold to trigger scaling')
param messageCountThreshold string = '5'

// Service Bus queue-based KEDA scaling rules.
// When messages accumulate beyond the threshold, KEDA adds replicas to drain the queue.
var serviceBusRules = [
  {
    name: 'servicebus-queue-scaling'
    custom: {
      type: 'azure-servicebus'
      metadata: {
        queueName: queueName
        messageCount: messageCountThreshold
        namespace: ''
        connectionFromEnv: ''
      }
      auth: !empty(serviceBusConnectionString) ? [
        {
          secretRef: 'servicebus-connection'
          triggerParameter: 'connection'
        }
      ] : []
    }
  }
]

@description('KEDA scaling rules for Service Bus queue-based scaling')
output serviceBusScalingRules array = serviceBusRules

@description('Service Bus secret definition for container app configuration')
output serviceBusSecret object = !empty(serviceBusConnectionString) ? {
  name: 'servicebus-connection'
  value: serviceBusConnectionString
} : {}
