param name string
param domainName string
param location string = resourceGroup().location
param networkSecurityGroupAssigned bool
param subnetName string
param virtualnetworkResourceGroupName string
param virtualNetworkName string

var virtualNetworkId = resourceId(virtualnetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', virtualNetworkName)

resource name_resource 'Microsoft.Web/hostingEnvironments@2020-12-01' = if (networkSecurityGroupAssigned) {
  name: name
  kind: 'ASEV2'
  location: location
  properties: {
    name: name
    location: location
    dnsSuffix: domainName
    ipsslAddressCount: 0
    internalLoadBalancingMode: 'Web'
    virtualNetwork: {
      id: virtualNetworkId
      subnet: subnetName
    }
  }
}