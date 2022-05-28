@description('Name of the application gateway resource')
param appGatewayName string

@description('Vnet subnet resource ID')
param subnetRef string

@description('Application gateway tier')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param appGatewayTier string = 'Standard_v2'

@description('back end pool ip addresses')
param backendPools array

@description('Http settings for access backend pools')
param backendHttpSettings array

@description('routing rules')
param routingRules array

@description('Probes to create')
param customProbes array = []

@description('Optionally set custom error pages')
param customErrorPages array = []

@description('routing')
param rewriteRules array = []

@description('Number of instances of the app gateway running')
@minValue(2)
@maxValue(75)
param capacity int = 2

@description('Set the private IP address for application gateway (public IP address only generated if empty)')
param privateIpAddress string = ''

@description('Reference ID for a public IP address')
param publicIpAddressId string = ''

@description('Http frontend port.')
param httpFrontendPort int = 80

@description('Https frontend port.')
param httpsFrontendPort int = 443

@description('The name of the key vault.')
param keyVaultName string = ''

@description('The name of the certificate/secret stored in key vault.')
param keyVaultSecretName string = ''

@description('The name of the user assigned identity.')
param userAssignedIdentityName string

@description('Storage account to archive logs to (leave blank to disable)')
param logStorageAccountId string = ''

@description('Log analytics workspace to send logs to (leave blank to disable)')
param logWorkspaceId string = ''

@description('Number of days to retain the log files for (set to 0 to disable retention policy)')
param logRetention int = 0
param location string = resourceGroup().location

var logDiagnosticEnabled = ((!empty(logStorageAccountId)) || (!empty(logWorkspaceId)))
var logRetentionEnabled = ((logRetention == 0) ? json('false') : json('true'))
var tier = {
  Standard_Small: 'Standard'
  Standard_Medium: 'Standard'
  Standard_Large: 'Standard'
  WAF_Medium: 'WAF'
  WAF_Large: 'WAF'
  Standard_v2: 'Standard_v2'
  WAF_v2: 'WAF_v2'
}
var frontendIp = {
  public: [
    {
      name: 'appGatewayPublicFrontendIp'
      properties: {
        PublicIPAddress: {
          id: publicIpAddressId
        }
      }
    }
  ]
  private: [
    {
      name: 'appGatewayPrivateFrontendIp'
      properties: {
        privateIpAddress: privateIpAddress
        privateIpAllocationMethod: 'Static'
        subnet: {
          id: subnetRef
        }
      }
    }
  ]
}
var useSslCerts = ((length(keyVaultName) > 0) && (length(keyVaultSecretName) > 0) && (length(userAssignedIdentityName) > 0))
var blankArray = []
var sslCerts = [
  {
    name: 'default-ssl-certificate'
    properties: {
      keyVaultSecretId: 'https://${keyVaultName}.vault.azure.net/secrets/${keyVaultSecretName}'
    }
  }
]
var httpListener = [
  {
    name: 'appGatewayHttpListener'
    properties: {
      FrontendIpConfiguration: {
        Id: '${appGatewayName_resource.id}/frontendIPConfigurations/${((length(privateIpAddress) > 0) ? 'appGatewayPrivateFrontendIp' : 'appGatewayPublicFrontendIp')}'
      }
      FrontendPort: {
        Id: '${appGatewayName_resource.id}/frontendPorts/default-frontend-http-port'
      }
      Protocol: 'Http'
      customErrorConfigurations: customErrorPages
    }
  }
]
var httpsListener = [
  {
    name: 'appGatewayHttpsListener'
    properties: {
      FrontendIpConfiguration: {
        Id: '${appGatewayName_resource}/frontendIPConfigurations/${((length(privateIpAddress) > 0) ? 'appGatewayPrivateFrontendIp' : 'appGatewayPublicFrontendIp')}'
      }
      FrontendPort: {
        Id: '${appGatewayName_resource}/frontendPorts/default-frontend-https-port'
      }
      SslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, 'default-ssl-certificate')
      }
      Protocol: 'Https'
      customErrorConfigurations: customErrorPages
    }
  }
]
var httpRouting = [
  {
    Name: 'defaultHttpRoutingRule'
    properties: {
      RuleType: 'PathBasedRouting'
      httpListener: {
        id: '${appGatewayName_resource.id}/httpListeners/appGatewayHttpListener'
      }
      urlPathMap: {
        id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', appGatewayName, 'default-path-map')
      }
    }
  }
]
var httpsRouting = [
  {
    Name: 'defaultHttpsRoutingRule'
    properties: {
      RuleType: 'PathBasedRouting'
      httpListener: {
        id: '${appGatewayName_resource.id}/httpListeners/appGatewayHttpsListener'
      }
      urlPathMap: {
        id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', appGatewayName, 'default-path-map')
      }
    }
  }
]
var rewriteRuleSets = [
  {
    name: 'defaultRewriteRulesSet'
    type: 'Microsoft.Network/applicationGateways/rewriteRuleSets'
    properties: {
      rewriteRules: rewriteRules
    }
  }
]
var rewriteRuleSetsId = {
  id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', appGatewayName, 'defaultRewriteRulesSet')
}
var backendAddressPools = [for item in backendPools: {
  name: item.name
  properties: {
    BackendAddresses: [
      {
        fqdn: item.fqdn
      }
    ]
  }
}]
var urlPathRules = [for item in routingRules: {
  name: item.name
  properties: {
    backendAddressPool: {
      id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, item.backendPool)
    }
    paths: item.paths
    backendHttpSettings: {
      id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, item.backendHttp)
    }
    rewriteRuleSet: ((length(rewriteRules) > 0) ? rewriteRuleSetsId : json('null'))
  }
}]
var backendHttpSettings_var = [for item in backendHttpSettings: {
  name: item.name
  properties: {
    port: item.port
    protocol: item.protocol
    pickHostNameFromBackendAddress: item.hostnameFromBackendAddress
    requestTimeout: (contains(item, 'timeout') ? item.timeout : 30)
    path: (contains(item, 'backendPath') ? item.backendPath : json('null'))
    authenticationCertificates: (contains(item, 'authCerts') ? item.authCerts : blankArray)
    trustedRootCertificates: (contains(item, 'rootCerts') ? item.rootCerts : blankArray)
    probe: (contains(item, 'probeName') ? json('{ "id": "${appGatewayName_resource.id}/probes/${item.probeName}"}') : json('null'))
  }
}]

resource appGatewayName_resource 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: appGatewayTier
      tier: tier[appGatewayTier]
      capacity: capacity
    }
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20170401S'
    }
    sslCertificates: (useSslCerts ? sslCerts : blankArray)
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendIPConfigurations: (((length(privateIpAddress) > 0) && (length(publicIpAddressId) > 0)) ? union(frontendIp.public, frontendIp.private) : ((length(privateIpAddress) > 0) ? frontendIp.private : ((length(publicIpAddressId) > 0) ? frontendIp.public : blankArray)))
    frontendPorts: [
      {
        name: 'default-frontend-http-port'
        properties: {
          port: httpFrontendPort
        }
      }
      {
        name: 'default-frontend-https-port'
        properties: {
          port: httpsFrontendPort
        }
      }
    ]
    probes: customProbes
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettings_var
    httpListeners: (useSslCerts ? union(httpListener, httpsListener) : httpListener)
    urlPathMaps: [
      {
        name: 'default-path-map'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, backendPools[0].name)
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, backendHttpSettings[0].name)
          }
          pathRules: urlPathRules
          defaultRewriteRuleSet: ((length(rewriteRules) > 0) ? rewriteRuleSetsId : json('null'))
        }
      }
    ]
    requestRoutingRules: (useSslCerts ? union(httpRouting, httpsRouting) : httpRouting)
    rewriteRuleSets: ((length(rewriteRules) > 0) ? rewriteRuleSets : blankArray)
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', userAssignedIdentityName)}': {}
    }
  }
}

resource appGatewayName_Microsoft_Insights_appGatewayName_ds 'Microsoft.Network/applicationGateways/providers/diagnosticSettings@2017-05-01-preview' = if (logDiagnosticEnabled) {
  name: '${appGatewayName}/Microsoft.Insights/${appGatewayName}-ds'
  properties: {
    name: '${appGatewayName}-diagnositics'
    storageAccountId: (empty(logStorageAccountId) ? json('null') : logStorageAccountId)
    workspaceId: (empty(logWorkspaceId) ? json('null') : logWorkspaceId)
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          days: logRetention
          enabled: logRetentionEnabled
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          days: logRetention
          enabled: logRetentionEnabled
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          days: logRetention
          enabled: logRetentionEnabled
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: logRetention
          enabled: logRetentionEnabled
        }
      }
    ]
  }
  dependsOn: [
    appGatewayName_resource
  ]
}
