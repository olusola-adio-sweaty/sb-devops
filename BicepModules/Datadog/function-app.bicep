@description('The name of the function app ')
param functionAppName string = 'datadog-functionapp-${newGuid()}'

@description('The name of the function app ')
param functionAppNameInsights string = 'datadog-functionapp-${newGuid()}'

@description('The name of the function.')
param functionName string = 'datadog-function'

@description('The name of the eventhub.')
param eventhubName string = 'datadog-eventhub'

@description('The name of the eventhub namespace.')
param eventhubNamespace string

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
param location string = resourceGroup().location

var storageAccountName_var = '${uniqueString(resourceGroup().id)}storageacct'
var connectionStringKey = 'Datadog-${eventhubNamespace}-AccessKey'
var authRule = resourceId('Microsoft.EventHub/namespaces/authorizationRules', eventhubNamespace, 'RootManageSharedAccessKey')

resource storageAccountName 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName_var
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource functionAppNameInsights_resource 'Microsoft.Insights/components@2020-02-02' = {
  name: functionAppNameInsights
  location: location
  kind: 'web'
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', functionAppNameInsights)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
}

resource functionAppName_resource 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    clientAffinityEnabled: false
    siteConfig: {
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: functionAppNameInsights_resource.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DD_API_KEY'
          value: apiKey
        }
        {
          name: 'DD_SITE'
          value: datadogSite
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName_var};AccountKey=${listkeys(storageAccountName.id, '2021-09-01').keys[0].value};EndpointSuffix=${endpointSuffix};'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: connectionStringKey
          value: listKeys(authRule, '2017-04-01').primaryConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName_var};AccountKey=${listkeys(storageAccountName.id, '2021-09-01').keys[0].value};EndpointSuffix=${endpointSuffix};'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }
      ]
    }
  }
}

resource functionAppName_functionName_1 'Microsoft.Web/sites/functions@2020-06-01' = [for i in range(0, copies): {
  name: '${functionAppName}/${functionName}-${(i + 1)}'
  properties: {
    config: {
      bindings: [
        {
          name: 'eventHubMessages'
          type: 'eventHubTrigger'
          direction: 'in'
          eventHubName: '${eventhubName}-${(i + 1)}'
          connection: connectionStringKey
          cardinality: 'many'
          dataType: ''
          consumerGroup: '$Default'
        }
      ]
      disabled: false
    }
    files: {
      'index.js': functionCode
    }
  }
  dependsOn: [
    functionAppName_resource
  ]
}]
