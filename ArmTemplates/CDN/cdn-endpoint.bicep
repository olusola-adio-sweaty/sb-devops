@description('Name of Content Delivery Network profile')
param cdnProfileName string

@description('Name of the endpoint has to be unique')
param cdnEndPointName string
param originHostName string

@description('The cache expiration to set in days when setting the Caching behaviour to Override')
param cacheExpirationOverride string = ''

@allowed([
  'GeneralWebDelivery'
  'GeneralMediaStreaming'
  'VideoOnDemandMediaStreaming'
  'LargeFileDownload'
  'DynamicSiteAcceleration'
])
param optimizationType string = 'GeneralWebDelivery'
param customDomainName string = ''
param isHttpAllowed bool = false

@allowed([
  'NotSet'
  'IgnoreQueryString'
  'UseQueryString'
  'BypassCaching'
])
param queryStringCachingBehavior string = 'IgnoreQueryString'
param originPath string = ''
param location string = resourceGroup().location

var contentTypesToCompress = [
  'application/eot'
  'application/font'
  'application/font-sfnt'
  'application/javascript'
  'application/json'
  'application/opentype'
  'application/otf'
  'application/pkcs7-mime'
  'application/truetype'
  'application/ttf'
  'application/vnd.ms-fontobject'
  'application/xhtml+xml'
  'application/xml'
  'application/xml+rss'
  'application/x-font-opentype'
  'application/x-font-truetype'
  'application/x-font-ttf'
  'application/x-httpd-cgi'
  'application/x-javascript'
  'application/x-mpegurl'
  'application/x-opentype'
  'application/x-otf'
  'application/x-perl'
  'application/x-ttf'
  'font/eot'
  'font/ttf'
  'font/otf'
  'font/opentype'
  'image/svg+xml'
  'text/css'
  'text/csv'
  'text/html'
  'text/javascript'
  'text/js'
  'text/plain'
  'text/richtext'
  'text/tab-separated-values'
  'text/xml'
  'text/x-script'
  'text/x-component'
  'text/x-java-source'
]
var customDomainEnabled = (length(customDomainName) > 0)
var deliveryPolicy = {
  noPolicy: null
  overridePolicy: {
    description: 'Override Delivery Policy'
    rules: [
      {
        order: 0
        conditions: []
        actions: [
          {
            name: 'CacheExpiration'
            parameters: {
              '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleCacheExpirationActionParameters'
              cacheBehavior: 'Override'
              cacheDuration: '${cacheExpirationOverride}.00:00:00'
              cacheType: 'All'
            }
          }
        ]
      }
    ]
  }
}
var fullEndpointName_var = '${cdnProfileName}/${cdnEndPointName}'
var origin = [
  {
    name: replace(originHostName_var, '.', '-')
    properties: {
      hostName: originHostName_var
      httpPort: 80
      httpsPort: 443
    }
  }
]
var originHostName_var = replace(replace(originHostName, 'https://', ''), '/', '')
var endpointProperties = {
  withOriginPath: {
    originHostHeader: originHostName_var
    originPath: originPath
    contentTypesToCompress: contentTypesToCompress
    isCompressionEnabled: true
    isHttpAllowed: isHttpAllowed
    isHttpsAllowed: true
    queryStringCachingBehavior: queryStringCachingBehavior
    optimizationType: optimizationType
    deliveryPolicy: ((cacheExpirationOverride == '') ? deliveryPolicy.noPolicy : deliveryPolicy.overridePolicy)
    origins: origin
  }
  withoutOriginPath: {
    originHostHeader: originHostName_var
    contentTypesToCompress: contentTypesToCompress
    isCompressionEnabled: true
    isHttpAllowed: isHttpAllowed
    isHttpsAllowed: true
    queryStringCachingBehavior: queryStringCachingBehavior
    optimizationType: optimizationType
    deliveryPolicy: ((cacheExpirationOverride == '') ? deliveryPolicy.noPolicy : deliveryPolicy.overridePolicy)
    origins: origin
  }
}

resource fullEndpointName 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  name: fullEndpointName_var
  location: location
  properties: ((originPath == '') ? endpointProperties.withoutOriginPath : endpointProperties.withOriginPath)
}

resource fullEndpointName_customDomainEnabled_customDomainName_placeholder 'Microsoft.Cdn/profiles/endpoints/customDomains@2021-06-01' = if (customDomainEnabled) {
  parent: fullEndpointName
  name: (customDomainEnabled ? replace(customDomainName, '.', '-') : 'placeholder')
  properties: {
    hostName: customDomainName
  }
}

output endpointHostName string = reference(cdnEndPointName).hostname
