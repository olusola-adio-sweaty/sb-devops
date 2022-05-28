@description('Name of the Service Bus namespace.')
param serviceBusNamespaceName string

@description('The messaging tier for service Bus namespace.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string = 'Standard'
param location string = resourceGroup().location

resource serviceBusNamespaceName_resource 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: serviceBusSku
  }
}

resource serviceBusNamespaceName_ReadWrite 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2018-01-01-preview' = {
  parent: serviceBusNamespaceName_resource
  name: 'ReadWrite'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource serviceBusNamespaceName_Read 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2018-01-01-preview' = {
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

output ServiceBusEndpoint string = listkeys(serviceBusNamespaceName_ReadWrite.id, '2017-04-01').primaryConnectionString
output ServiceBusEndpointReadOnly string = listkeys(serviceBusNamespaceName_Read.id, '2017-04-01').primaryConnectionString