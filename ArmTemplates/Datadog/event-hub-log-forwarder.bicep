@description('Name of EventHub namespace, which must be globally unique.')
param eventHubNamespace string = 'datadog-ns-${newGuid()}'

@description('Name of Event Hub')
param eventHubName string = 'datadog-eventhub'

@description('The name of the function app ')
param functionAppName string = 'datadog-functionapp-${newGuid()}'

@description('The name of the function.')
param functionName string = 'datadog-function'

@description('The name of the function.')
param functionAppNameInsights string = 'datadog-function'

@description('Code for the function to run, saved into index.js')
param functionCode string

@description('Datadog API key')
param apiKey string

@description('Datadog site to send logs')
param datadogSite string = 'datadoghq.com'

@description('Endpoint suffix for storage account')
param endpointSuffix string = environment().suffixes.storage

@description('number of functins and event hubs')
param copies int

@description('Environment')
param env string
param location string = resourceGroup().location

var appInsights = 'sb-${env}-api-datadog-ingest-ai'
var logAnalyticWorkspace_var = 'sb-${env}-api-datadog-la'

module eventHubTemplate './event-hub.bicep' /*TODO: replace with correct path to [variables('eventHubTemplateLink')]*/ = {
  name: 'eventHubTemplate'
  params: {
    eventHubNamespace: eventHubNamespace
    eventHubName: eventHubName
    copies: copies
    location: location
  }
}

module functionAppTemplate './function-app.bicep' /*TODO: replace with correct path to [variables('functionAppTemplateLink')]*/ = {
  name: 'functionAppTemplate'
  params: {
    eventhubNamespace: eventHubNamespace
    eventhubName: eventHubName
    functionAppName: functionAppName
    functionName: functionName
    functionCode: functionCode
    apiKey: apiKey
    datadogSite: datadogSite
    endpointSuffix: endpointSuffix
    functionAppNameInsights: functionAppNameInsights
    copies: copies
    location: location
  }
  dependsOn: [
    eventHubTemplate
  ]
}

resource appInsights_1 'microsoft.insights/components@2020-02-02' = [for i in range(0, copies): {
  name: '${appInsights}-${(i + 1)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}]

resource logAnalyticWorkspace 'microsoft.operationalinsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticWorkspace_var
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output eventHubNamespace string = eventHubNamespace
