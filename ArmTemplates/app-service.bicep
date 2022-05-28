@description('App Service name to be created')
param appServiceName string

@description('App Service Plan to put the app service inside')
param appServicePlanName string

@description('Resource group the App Service Plan is within')
param appServicePlanResourceGroup string = resourceGroup().name

@description('Type of site, either (web)app or functionapp')
@allowed([
  'app'
  'functionapp'
])
param appServiceType string = 'app'

@description('Array of app settings to be created')
param appServiceAppSettings array = []

@description('Array of connection strings to be created')
param appServiceConnectionStrings array = []
param customHostName string = ''

@description('')
param certificateThumbprint string = ''
param deployStagingSlot bool = true
param clientAffinity bool = false
param location string = resourceGroup().location

var useCustomHostname = (length(customHostName) > 0)
var appServicePlanId = resourceId(appServicePlanResourceGroup, 'Microsoft.Web/serverfarms', appServicePlanName)

resource appServiceName_resource 'Microsoft.Web/sites@2020-12-01' = {
  name: appServiceName
  kind: appServiceType
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    clientAffinityEnabled: clientAffinity
    siteConfig: {
      alwaysOn: true
      appSettings: appServiceAppSettings
      connectionStrings: appServiceConnectionStrings
      phpVersion: 'off'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
  dependsOn: []
}

resource appServiceName_staging 'Microsoft.Web/sites/slots@2020-12-01' = if (deployStagingSlot) {
  parent: appServiceName_resource
  name: 'staging'
  location: location
  properties: {
    clientAffinityEnabled: clientAffinity
    siteConfig: {
      appSettings: appServiceAppSettings
      connectionStrings: appServiceConnectionStrings
      phpVersion: 'off'
    }
  }
}

resource appServiceName_useCustomHostname_customHostname_placeholder 'Microsoft.Web/sites/hostnameBindings@2020-12-01' = if (useCustomHostname) {
  parent: appServiceName_resource
  name: (useCustomHostname ? customHostName : 'placeholder')
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
