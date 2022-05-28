param eventgridTopicName string
param eventgridTopicSku string
param location string = resourceGroup().location

resource eventgridTopicName_resource 'Microsoft.EventGrid/topics@2021-12-01' = {
  name: eventgridTopicName
  location: location
  tags: {}
  sku: {
    name: eventgridTopicSku
  }
  properties: {
    inputSchema: 'EventGridSchema'
    publicNetworkAccess: 'Enabled'
    inboundIpRules: []
  }
}