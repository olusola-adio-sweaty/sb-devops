@description('Name of an existing Service Bus namespace to add the topic to')
param serviceBusNamespaceName string

@description('Topic name to add to Service Bus')
param serviceBusTopicName string

@description('Default time to live (defaults to 90 days)')
param messageDefaultTTL string = 'P90D'

@description('Default topic max size (in Mb)')
param topicMaxSizeMb int = 1024

resource serviceBusNamespaceName_serviceBusTopicName 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = {
  name: '${serviceBusNamespaceName}/${serviceBusTopicName}'
  properties: {
    path: serviceBusTopicName
    defaultMessageTimeToLive: messageDefaultTTL
    maxSizeInMegabytes: topicMaxSizeMb
  }
}