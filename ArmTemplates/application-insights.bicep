@description('Name of the application insights resource')
param appInsightsName string

@description('Name of the app service the resource monitors (tag only)')
param attachedService string = ''
param location string = resourceGroup().location

var withoutAttachedService = {}
var withAttachedService = {
  'hidden-link:${resourceId('Microsoft.Web/sites', attachedService)}': 'Resource'
}

resource appInsightsName_resource 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: ((attachedService == '') ? withoutAttachedService : withAttachedService)
  properties: {
    Application_Type: 'web'
  }
}

output InstrumentationKey string = appInsightsName_resource.properties.InstrumentationKey
output AppId string = appInsightsName_resource.properties.AppId
