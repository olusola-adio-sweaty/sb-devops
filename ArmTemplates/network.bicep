@description('The name of new Azure VNet where you can deploy Azure Sql Managed Instances and the resources that use them')
param virtualNetworkPrefix string

@description('First 2 octects of VNet Private IP address range (VNet prefix)')
param virtualNetworkAddressPrefix string = '10.0'

@description('Array of routed subnets to create')
param virtualNetworkRoutedSubnets array = []

@description('Array of non-routed subnets to create')
param virtualNetworkNonRoutedSubnets array = []
param location string = resourceGroup().location

var virtualNetworkName_var = '${virtualNetworkPrefix}-vnet'
var routeTableName_var = '${virtualNetworkPrefix}-rt'
var localIpAddressRange = '${virtualNetworkAddressPrefix}.0.0/16'
var allSubnets = union(virtualNetworkRoutedSubnets, virtualNetworkNonRoutedSubnets)
var routeTable = {
  id: routeTableName.id
}
var subnets = [for (item, i) in allSubnets: {
  name: item
  properties: {
    addressPrefix: '${virtualNetworkAddressPrefix}.${i}.0/24'
    routeTable: ((i < length(virtualNetworkRoutedSubnets)) ? routeTable : json('null'))
  }
}]

resource routeTableName 'Microsoft.Network/routeTables@2021-08-01' = {
  name: routeTableName_var
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'subnet_to_vnetlocal'
        properties: {
          addressPrefix: localIpAddressRange
          nextHopType: 'VnetLocal'
        }
      }
      {
        name: 'mi-0-5-nexthop-internet'
        properties: {
          addressPrefix: '0.0.0.0/5'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-8-7-nexthop-internet'
        properties: {
          addressPrefix: '8.0.0.0/7'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-11-8-nexthop-internet'
        properties: {
          addressPrefix: '11.0.0.0/8'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-12-6-nexthop-internet'
        properties: {
          addressPrefix: '12.0.0.0/6'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-16-4-nexthop-internet'
        properties: {
          addressPrefix: '16.0.0.0/4'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-32-3-nexthop-internet'
        properties: {
          addressPrefix: '32.0.0.0/3'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-64-2-nexthop-internet'
        properties: {
          addressPrefix: '64.0.0.0/2'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-128-3-nexthop-internet'
        properties: {
          addressPrefix: '128.0.0.0/3'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-160-5-nexthop-internet'
        properties: {
          addressPrefix: '160.0.0.0/5'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-168-6-nexthop-internet'
        properties: {
          addressPrefix: '168.0.0.0/6'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-172-1-nexthop-internet'
        properties: {
          addressPrefix: '172.0.0.0/12'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-172-32-11-nexthop-internet'
        properties: {
          addressPrefix: '172.32.0.0/11'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-172-64-10-nexthop-internet'
        properties: {
          addressPrefix: '172.64.0.0/10'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-172-128-9-nexthop-internet'
        properties: {
          addressPrefix: '172.128.0.0/9'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-173-8-nexthop-internet'
        properties: {
          addressPrefix: '173.0.0.0/8'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-174-7-nexthop-internet'
        properties: {
          addressPrefix: '174.0.0.0/7'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-176-4-nexthop-internet'
        properties: {
          addressPrefix: '176.0.0.0/4'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-9-nexthop-internet'
        properties: {
          addressPrefix: '192.0.0.0/9'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-128-11-nexthop-internet'
        properties: {
          addressPrefix: '192.128.0.0/11'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-160-13-nexthop-internet'
        properties: {
          addressPrefix: '192.160.0.0/13'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-169-16-nexthop-internet'
        properties: {
          addressPrefix: '192.169.0.0/16'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-170-15-nexthop-internet'
        properties: {
          addressPrefix: '192.170.0.0/15'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-172-14-nexthop-internet'
        properties: {
          addressPrefix: '192.172.0.0/14'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-176-12-nexthop-internet'
        properties: {
          addressPrefix: '192.176.0.0/12'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-192-192-10-nexthop-internet'
        properties: {
          addressPrefix: '192.192.0.0/10'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-193-8-nexthop-internet'
        properties: {
          addressPrefix: '193.0.0.0/8'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-194-7-nexthop-internet'
        properties: {
          addressPrefix: '194.0.0.0/7'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-196-6-nexthop-internet'
        properties: {
          addressPrefix: '196.0.0.0/6'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-200-5-nexthop-internet'
        properties: {
          addressPrefix: '200.0.0.0/5'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-208-4-nexthop-internet'
        properties: {
          addressPrefix: '208.0.0.0/4'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'mi-224-3-nexthop-internet'
        properties: {
          addressPrefix: '224.0.0.0/3'
          nextHopType: 'Internet'
        }
      }
    ]
  }
}

resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        localIpAddressRange
      ]
    }
    subnets: subnets
  }
}

output virtualNetworkName string = virtualNetworkName_var
output routeTableName string = routeTableName_var
output routeTableId string = routeTableName.id