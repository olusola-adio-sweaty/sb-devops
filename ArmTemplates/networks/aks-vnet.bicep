param aksNodeResourceGroupName string
param aksRouteTableName string
param aksSubnetName string
param aksAppGatewaySubnetName string
param virtualNetworkAddressPrefix string = '10.0'
param vnetName string
param location string = resourceGroup().location

var routeTable = {
  id: resourceId(aksNodeResourceGroupName, 'Microsoft.Network/routeTables', aksRouteTableName)
}

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${virtualNetworkAddressPrefix}.0.0/16'
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: '${virtualNetworkAddressPrefix}.0.0/24'
          routeTable: ((length(aksRouteTableName) > 0) ? routeTable : json('null'))
        }
      }
      {
        name: aksAppGatewaySubnetName
        properties: {
          addressPrefix: '${virtualNetworkAddressPrefix}.1.0/24'
        }
      }
    ]
  }
}