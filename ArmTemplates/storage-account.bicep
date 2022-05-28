@description('Name of the storage account')
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Premium_LRS'
])
param accountType string = 'Standard_LRS'

@description('This setting is required if using BlobStorage as the storageKind, otherwise can be left blank')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
])
param storageKind string = 'StorageV2'
param location string = resourceGroup().location

var EndPointSuffix = environment().suffixes.storage

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: accountType
  }
  kind: storageKind
  tags: {}
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: accessTier
    supportsHttpsTrafficOnly: true
  }
}

output storageKey string = listKeys(storageAccountName_resource.id, providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value};EndpointSuffix=${EndPointSuffix}'
