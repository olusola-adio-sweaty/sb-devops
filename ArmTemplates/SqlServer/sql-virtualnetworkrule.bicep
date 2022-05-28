param sqlServerName string
param subnetName string
param virtualNetworkRuleName string
param vnetName string
param vnetResourceGroupName string
param ignoreMissingVnetServiceEndpoint bool = false

resource sqlServerName_virtualNetworkRuleName 'Microsoft.Sql/servers/virtualNetworkRules@2021-11-01-preview' = {
  name: '${sqlServerName}/${virtualNetworkRuleName}'
  properties: {
    virtualNetworkSubnetId: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
  }
}