param adminEmail string
param apimServiceName string

@description('Abbreviated name for the environment, eg: AT, TEST, PP, PRD')
param environmentName string = ''

@description('The hostname used by the API (Proxy) and Developer Portal (Portal)')
param hostnameRoot string = ''
param organizationName string

@description('The certificate identifier, eg https://dss-dev-shared-kv.vault.azure.net/certificates/wildcard-dss-nationalcareersservice-direct-gov-uk/identifierstringabc123')
param portalKeyVaultCertificatePath string = ''

@description('The certificate identifier, eg https://dss-dev-shared-kv.vault.azure.net/certificates/wildcard-dss-nationalcareersservice-direct-gov-uk/identifierstringabc123')
param proxyKeyVaultCertificatePath string = ''

@allowed([
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param skuTier string = 'Developer'
param capacity int = 1
param subnetName string = ''
param vnetResourceGroup string = ''
param vnetName string = ''
param location string = resourceGroup().location

var apimPortalHostname = ((environmentName == 'PRD') ? 'portal.${hostnameRoot}' : '${toLower(environmentName)}-portal.${hostnameRoot}')
var apimProxyHostname = ((environmentName == 'PRD') ? concat(hostnameRoot) : '${toLower(environmentName)}.${hostnameRoot}')
var apimNewPortalHostnameProperties = {
  type: 'DeveloperPortal'
  hostName: apimPortalHostname
  keyVaultId: portalKeyVaultCertificatePath
  negotiateClientCertificate: false
}
var apimProxyHostnameProperties = {
  type: 'Proxy'
  hostName: apimProxyHostname
  keyVaultId: proxyKeyVaultCertificatePath
  defaultSslBinding: true
  negotiateClientCertificate: false
}
var apimHostnameProperties = ((hostnameRoot == '') ? array(json('[]')) : [
  apimProxyHostnameProperties
  apimNewPortalHostnameProperties
])
var apimSubnetId = ((subnetName == '') ? '' : '${apimVnetId}/subnets/${subnetName}')
var apimSubnetConfig = {
  withSubnet: {
    subnetResourceId: apimSubnetId
  }
  withoutSubnet: null
}
var apimVnetId = ((subnetName == '') ? '' : resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks', vnetName))

resource apimServiceName_resource 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimServiceName
  tags: {}
  properties: {
    hostnameConfigurations: apimHostnameProperties
    publisherEmail: adminEmail
    publisherName: organizationName
    virtualNetworkType: ((subnetName == '') ? 'None' : 'External')
    virtualNetworkConfiguration: ((subnetName == '') ? apimSubnetConfig.withoutSubnet : apimSubnetConfig.withSubnet)
  }
  sku: {
    name: skuTier
    capacity: capacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}