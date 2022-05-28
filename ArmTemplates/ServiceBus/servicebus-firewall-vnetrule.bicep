@description('The name of the Service Bus Namespace to ad the VNet rule to.')
param servicebusName string

@description('An array of Subnet names to add to the VNet rule.')
param subnetNames array

@description('Name of the VNet that contains the subnets.')
param vnetName string

@description('Name of the Vnet\'s resource group.')
param vnetResourceGroup string

@description('An array of IP Addresses.')
param ipRules array = []
param location string = resourceGroup().location

var namespaceNetworkRuleSetName_var = '${servicebusName}/default'
var subnetCopy = [for item in subnetNames: '${resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks', vnetName)}/subnets/${item}']

resource namespaceNetworkRuleSetName 'Microsoft.ServiceBus/namespaces/networkruleset@2021-11-01' = {
  name: namespaceNetworkRuleSetName_var
  location: location
  tags: {}
  properties: {
    virtualNetworkRules: [for item in subnetCopy: {
      subnet: {
        id: item
      }
      ignoreMissingVnetServiceEndpoint: false
    }]
    ipRules: ipRules
    defaultAction: 'Deny'
  }
}