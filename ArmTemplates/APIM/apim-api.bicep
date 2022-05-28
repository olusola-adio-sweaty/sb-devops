param apimServiceName string
param apiName string

@description('The product identifier, this is different to the Display Name (which may contain spaces).')
param apimProductInstanceName string = ''
param apimLoggerName string = ''

@description('The version of the API, must be in the format v1, v2 ... v10, etc')
param apimVersion string = ''

@description('Relative URL uniquely identifying this API and all of its resource paths within the API Management service instance, defaults to apiName')
param apiSuffix string = ''

@description('The percentage of requests to APIM to be sampled by Application Insights')
@metadata({
  comment: 'Sampling percentage cannot currently be set within an ARM template.  Requires Azure REST API call.'
})
@minValue(0)
@maxValue(100)
param loggerSamplingPercentage int = 100
param oauthAuthenticationServer string = ''

var apimApiVersionName = ((apimVersion == '') ? apiName : '${apiName}-${apimVersion}')
var apiSuffixPath = ((apiSuffix == '') ? apiName : apiSuffix)
var apiProperties = {
  noversion: {
    authenticationSettings: authenticationProvider
    displayName: apimApiVersionName
    path: apiSuffixPath
    protocols: [
      'https'
    ]
  }
  versioned: {
    apiVersion: apimVersion
    apiVersionSetId: resourceId('Microsoft.ApiManagement/service/api-version-sets', apimServiceName, versionSetName)
    authenticationSettings: authenticationProvider
    displayName: apimApiVersionName
    path: apiSuffixPath
    protocols: [
      'https'
    ]
  }
}
var authenticationProvider = ((oauthAuthenticationServer == '') ? noAuthenticationProvider : oauthAuthenticationProvider)
var loggerName = ((apimLoggerName == '') ? 'no-logger' : apimLoggerName)
var noAuthenticationProvider = {
  oAuth2: null
  openid: null
}
var oauthAuthenticationProvider = {
  oAuth2: {
    authorizationServerId: oauthAuthenticationServer
  }
}
var versionSetName = '${apiName}-versionset'

resource apimServiceName_apimApiVersionName 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${apimServiceName}/${apimApiVersionName}'
  properties: ((apimVersion == '') ? apiProperties.noversion : apiProperties.versioned)
  dependsOn: []
}

resource apimServiceName_apimApiVersionName_applicationinsights 'Microsoft.ApiManagement/service/apis/diagnostics@2021-12-01-preview' = if (length(apimLoggerName) > 0) {
  parent: apimServiceName_apimApiVersionName
  name: 'applicationinsights'
  properties: {
    enabled: true
    alwaysLog: 'allErrors'
    loggerId: resourceId('Microsoft.ApiManagement/service/loggers', apimServiceName, apimLoggerName)
    sampling: {
      samplingType: 'fixed'
      percentage: loggerSamplingPercentage
    }
    enableHttpCorrelationHeaders: true
  }
}

resource apimServiceName_apimApiVersionName_applicationinsights_loggerName 'Microsoft.ApiManagement/service/apis/diagnostics/loggers@2021-08-01' = if (length(apimLoggerName) > 0) {
  parent: apimServiceName_apimApiVersionName_applicationinsights
  name: loggerName
}

resource apimServiceName_apimProductInstanceName_apimApiVersionName 'Microsoft.ApiManagement/service/products/apis@2021-12-01-preview' = if (apimProductInstanceName != '') {
  name: '${apimServiceName}/${apimProductInstanceName}/${apimApiVersionName}'
  dependsOn: [
    apimServiceName_apimApiVersionName
  ]
}
