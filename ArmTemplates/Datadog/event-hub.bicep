@description('Name of EventHub namespace')
param eventHubNamespace string

@description('Name of Event Hub')
param eventHubName string = 'datadog-eventhub'

@description('number of functins and event hubs')
param copies int
param location string = resourceGroup().location

resource eventHubNamespace_resource 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespace
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {}
}

resource eventHubNamespace_eventHubName_1 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = [for i in range(0, copies): {
  name: '${eventHubNamespace}/${eventHubName}-${(i + 1)}'
  properties: {}
  dependsOn: [
    eventHubNamespace_resource
  ]
}]

resource eventHubNamespace_DatadogRule_1 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = [for i in range(0, copies): {
  name: '${eventHubNamespace}/DatadogRule-${(i + 1)}'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
  dependsOn: [
    eventHubNamespace_resource
  ]
}]