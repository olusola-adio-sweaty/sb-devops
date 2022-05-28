@description('The name of the Managed Cluster resource.')
param clusterName string
param dnsServiceIp string

@description('The version of Kubernetes.')
param kubernetesVersion string

@description('The name of the resource group used for nodes')
param nodeResourceGroup string
param serviceCidr string

@description('Subnet name that will contain the aks CLUSTER')
param subnetName string

@description('Name of an existing VNET that will contain this AKS deployment.')
param virtualNetworkName string

@description('Name of the existing VNET resource group')
param virtualNetworkResourceGroup string

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentNodeCount1 int = 2

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentNodeCount2 int = 4

@description('The name of the default system agent pool')
param agentPoolName1 string = 'systempool'

@description('The name of the default app agent pool')
param agentPoolName2 string = 'apppool'

@description('The sku of the machines that will be used for the system agentpool.')
param agent1VMSize string = 'Standard_D4s_v3'

@description('The sku of the machines that will be used for the app agentpool.')
param agent2VMSize string = 'Standard_DS12_v2'
param dockerBridgeCidr string = '172.17.0.1/16'

@description('The name of the resource group for log analytics')
param logAnalyticsResourceGroupName string = ''

@description('The name of the log analytics workspace that will be used for monitoring')
param logAnalyticsWorkspaceName string = ''
param podCidr string = '10.244.0.0/16'

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []
param location string = resourceGroup().location

var vnetSubnetId = resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var logAnalyticsId = resourceId(logAnalyticsResourceGroupName, 'Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
var addOnObject = {
  noAddons: json('null')
  omsAddon: {
    omsagent: {
      enabled: true
      config: {
        logAnalyticsWorkspaceResourceID: logAnalyticsId
      }
    }
  }
}

resource clusterName_resource 'Microsoft.ContainerService/managedClusters@2020-07-01' = {
  location: location
  name: clusterName
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: agentPoolName1
        count: agentNodeCount1
        vmSize: agent1VMSize
        osType: 'Linux'
        vnetSubnetID: vnetSubnetId
        type: 'VirtualMachineScaleSets'
        storageProfile: 'ManagedDisks'
        mode: 'System'
        maxPods: 30
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: agentPoolName2
        count: agentNodeCount2
        vmSize: agent2VMSize
        osType: 'Linux'
        vnetSubnetID: vnetSubnetId
        type: 'VirtualMachineScaleSets'
        storageProfile: 'ManagedDisks'
        mode: 'System'
        maxPods: 40
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
    addonProfiles: ((logAnalyticsWorkspaceName == '') ? addOnObject.noAddons : addOnObject.omsAddon)
    nodeResourceGroup: nodeResourceGroup
    enableRBAC: true
    aadProfile: {
      managed: true
      adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIp
      podCidr: podCidr
      dockerBridgeCidr: dockerBridgeCidr
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}