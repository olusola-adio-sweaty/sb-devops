@description('Service name must only contain lowercase letters, digits or dashes, cannot use dash as the first two or last one characters, cannot contain consecutive dashes, and is limited between 2 and 60 characters in length.')
@minLength(2)
@maxLength(60)
param azureSearchName string

@description('The SKU of the search service you want to create. E.g. free or standard')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param azureSearchSku string = 'basic'

@description('Replicas distribute search workloads across the service. You need 2 or more to support high availability (applies to Basic and Standard only).')
@minValue(1)
@maxValue(12)
param azureSearchReplicaCount int = 1

@description('Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple Azure Search units.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param azureSearchPartitionCount int = 1
param location string = resourceGroup().location

resource azureSearchName_resource 'Microsoft.Search/searchServices@2021-04-01-preview' = {
  name: azureSearchName
  location: location
  sku: {
    name: toLower(azureSearchSku)
  }
  properties: {
    replicaCount: azureSearchReplicaCount
    partitionCount: azureSearchPartitionCount
  }
}

#disable-next-line outputs-should-not-contain-secrets
output azureSearchPrimaryKey string = listAdminKeys(azureSearchName_resource.id, '2021-04-01-preview').PrimaryKey
