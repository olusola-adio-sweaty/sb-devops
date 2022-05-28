@description('Name of the Service Bus namespace.')
@metadata({
  comments: 'THIS TEMPLATE IS DEPRACTED - USE THE servicebus-namespace.json TEMPLATE INSTEAD'
})
param serviceBusNamespaceName string

@description('The messaging tier for service Bus namespace.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string = 'Standard'

@description('Names of service bus queues to create within the namespace.')
param serviceBusQueues array = []
param location string = resourceGroup().location

var deployQueues = (length(serviceBusQueues) > 0)

resource serviceBusNamespaceName_resource 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: serviceBusSku
  }
}

resource serviceBusNamespaceName_ReadWrite 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-11-01' = {
  parent: serviceBusNamespaceName_resource
  name: 'ReadWrite'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource serviceBusNamespaceName_Read 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-11-01' = {
  parent: serviceBusNamespaceName_resource
  name: 'Read'
  properties: {
    rights: [
      'Listen'
    ]
  }
  dependsOn: [
    serviceBusNamespaceName_ReadWrite
  ]
}

resource serviceBusNamespaceName_deployQueues_serviceBusQueues_placeholder 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = [for i in range(0, (deployQueues ? length(serviceBusQueues) : 1)): if (deployQueues) {
  name: '${serviceBusNamespaceName}/${(deployQueues ? serviceBusQueues[i] : 'placeholder')}'
  properties: {}
  dependsOn: [
    serviceBusNamespaceName_resource
  ]
}]

output ServiceBusEndpoint string = listkeys(serviceBusNamespaceName_ReadWrite.id, '2021-11-01').primaryConnectionString
output ServiceBusEndpointReadOnly string = listkeys(serviceBusNamespaceName_Read.id, '2021-11-01').primaryConnectionString