param name string
param agSubnetName string
param vnetName string
param vnetResourceGroupName string

@description('Restricts HTTP(S) traffic in the NSG to the passed in range')
param privateIpAddressRange string

@description('IP address of cloud service')
param cloudServiceIpAddress string
param location string = resourceGroup().location

var isIpArray = contains(privateIpAddressRange, ',')
var IpArray = split(privateIpAddressRange, ',')

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
          description: 'Allow HTTP access from the WAF'
          sourceAddressPrefix: (isIpArray ? json('null') : privateIpAddressRange)
          sourceAddressPrefixes: (isIpArray ? IpArray : json('[]'))
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '80'
          destinationAddressPrefix: reference(resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, agSubnetName), '2021-08-01', 'Full').properties.addressPrefix
        }
      }
      {
        name: 'Inbound_HTTPS'
        properties: {
          direction: 'Inbound'
          priority: 120
          access: 'Allow'
          description: 'Allow HTTPS access from the WAF'
          sourceAddressPrefix: (isIpArray ? json('null') : privateIpAddressRange)
          sourceAddressPrefixes: (isIpArray ? IpArray : json('[]'))
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '443'
          destinationAddressPrefix: reference(resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, agSubnetName), '2021-08-01', 'Full').properties.addressPrefix
        }
      }
      {
        name: 'CloudServiceIp'
        properties: {
          direction: 'Outbound'
          priority: 100
          access: 'Allow'
          description: 'Cloud service IP address to allow access to'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationPortRange: '*'
          destinationAddressPrefix: cloudServiceIpAddress
        }
      }
    ]
  }
}