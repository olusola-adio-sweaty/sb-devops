param apimServiceName string
param productDisplayName string = ''
param location string = resourceGroup().location

var apimLoggerName = ((length(productDisplayName) > 0) ? '${apimProductInstanceName}-logger' : '${apimServiceName}-logger')
var apimProductInstanceName = toLower(replace(productDisplayName, ' ', '-'))
var appInsightsName_var = ((length(productDisplayName) > 0) ? '${apimServiceName}-${apimProductInstanceName}-ai' : '${apimServiceName}-ai')

resource appInsightsName 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName_var
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource apimServiceName_apimLoggerName 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  name: '${apimServiceName}/${apimLoggerName}'
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appInsightsName.properties.InstrumentationKey
    }
    isBuffered: true
  }
}

output ApimLoggerName string = split(reference(apimServiceName_apimLoggerName.id, '2021-08-01', 'Full').resourceId, '/')[4]
output ApimLoggerResourceId string = reference(apimServiceName_apimLoggerName.id, '2021-08-01', 'Full').resourceId