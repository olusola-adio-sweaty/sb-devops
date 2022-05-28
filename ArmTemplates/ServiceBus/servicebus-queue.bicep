@description('Name of an existing Service Bus namespace to add the topic to')
param serviceBusNamespaceName string

@description('Queue name to add to Service Bus')
param queueName string

@description('Lock duration in seconds. (as ISO8601 timespan)')
param MessageLockDuration string = 'PT1M'

@description('The maximum size of the queue in MB.')
param MaxSizeInMegabytes int = 1024

@description('A value indicating if this queue requires duplicate detection.')
param EnableDuplicateDetection bool = false

@description('A value that indicates if the queue supports sessions.')
param EnableSessions bool = false

@description('When true,  messages are sent to a dead letter queue when they expire.')
param EnableDeadLettering bool = true

@description('The maximum number of times a message is delivered before it is expired')
param MaxDeliveryCount int = 10

resource serviceBusNamespaceName_queueName 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  name: '${serviceBusNamespaceName}/${queueName}'
  properties: {
    lockDuration: MessageLockDuration
    maxSizeInMegabytes: MaxSizeInMegabytes
    requiresDuplicateDetection: EnableDuplicateDetection
    requiresSession: EnableSessions
    deadLetteringOnMessageExpiration: EnableDeadLettering
    maxDeliveryCount: MaxDeliveryCount
  }
}