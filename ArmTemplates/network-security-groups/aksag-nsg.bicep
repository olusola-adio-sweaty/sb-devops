param name string
param agSubnetName string
param vnetName string
param vnetResourceGroupName string

@description('Restricts HTTP(S) traffic in the NSG to the passed in range')
param inboundIpAddressRange string
param location string = resourceGroup().location

var isIpArray = contains(inboundIpAddressRange, ',')
var IpArray = split(inboundIpAddressRange, ',')

resource name_resource 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: name
  location: location
  properties: {
    securityRules: [
      {
        name: 'HealthMonitoring'
        properties: {
          direction: 'Inbound'
          priority: 100
          access: 'Allow'
          description: 'Allow the App Gateway to retrieve health status data'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Inbound_HTTP'
        properties: {
          direction: 'Inbound'
          priority: 110
          access: 'Allow'
          description: 'Allow HTTP access only from allowed IP addresses'
          sourceAddressPrefix: (isIpArray ? json('null') : inboundIpAddressRange)
          sourceAddressPrefixes: (isIpArray ? IpArray : json('[]'))
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '7474'
          destinationAddressPrefix: reference(resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, agSubnetName), '2021-08-01', 'Full').properties.addressPrefix
        }
      }
      {
        name: 'Inbound_HTTPS'
        properties: {
          direction: 'Inbound'
          priority: 120
          access: 'Allow'
          description: 'Allow HTTPS access only from allowed IP addresses'
          sourceAddressPrefix: (isIpArray ? json('null') : inboundIpAddressRange)
          sourceAddressPrefixes: (isIpArray ? IpArray : json('[]'))
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '7473'
          destinationAddressPrefix: reference(resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, agSubnetName), '2021-08-01', 'Full').properties.addressPrefix
        }
      }
      {
        name: 'Inbound_BOLT'
        properties: {
          direction: 'Inbound'
          priority: 130
          access: 'Allow'
          description: 'Allow BOLT access only from allowed IP addresses'
          sourceAddressPrefix: (isIpArray ? json('null') : inboundIpAddressRange)
          sourceAddressPrefixes: (isIpArray ? IpArray : json('[]'))
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '7687'
          destinationAddressPrefix: reference(resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, agSubnetName), '2021-08-01', 'Full').properties.addressPrefix
        }
      }
    ]
  }
}