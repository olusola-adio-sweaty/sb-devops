@description('The Azure Cosmos DB name')
param cosmosDbName string

@description('The Azure Cosmos DB API type: Cassandra, Gremlin, MongoDB, SQL or Table')
@allowed([
  'Cassandra'
  'Gremlin'
  'MongoDB'
  'SQL'
  'Table'
])
param cosmosApiType string

@description('The Azure Cosmos DB default consistency level and configuration settings of the Cosmos DB account')
@allowed([
  'Eventual'
  'Session'
  'BoundedStaleness'
  'Strong'
  'ConsistentPrefix'
])
param defaultConsistencyLevel string

@description('Any additional IP addresses to add to the IP Range Filter in addition to the default addresses.  If more than 1 address is included they should be seperated by a comma, eg: 11.111.123.134,12.134.114.115')
param additionalIpAddresses string = ''

@description('Set this to false to remove access to CosmosDB from resources in Azure Data Centres')
param allowConnectionsFromAzureDataCenters bool = true
param location string = resourceGroup().location

var capabilityName = ((cosmosApiType == 'Cassandra') ? 'EnableCassandra' : ((cosmosApiType == 'Gremlin') ? 'EnableGremlin' : ((cosmosApiType == 'Table') ? 'EnableTable' : '')))
var emptyCapabilities = []
var enabledCapabilities = [
  {
    name: capabilityName
  }
]
var cosmosResourceProperties = {
  WithIpFilter: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
    }
    capabilities: ((capabilityName == '') ? emptyCapabilities : enabledCapabilities)
    databaseAccountOfferType: 'Standard'
    ipRangeFilter: '104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,${(allowConnectionsFromAzureDataCenters ? '0.0.0.0,' : '')}${additionalIpAddresses}'
  }
  WithoutIpFilter: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
    }
    capabilities: ((capabilityName == '') ? emptyCapabilities : enabledCapabilities)
    databaseAccountOfferType: 'Standard'
  }
}

resource cosmosDbName_resource 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: cosmosDbName
  location: location
  kind: ((cosmosApiType == 'MongoDB') ? 'MongoDB' : 'GlobalDocumentDB')
  properties: ((additionalIpAddresses == '') ? cosmosResourceProperties.WithoutIpFilter : cosmosResourceProperties.WithIpFilter)
  tags: {
    defaultExperience: ((cosmosApiType == 'SQL') ? 'DocumentDB' : cosmosApiType)
  }
}

output PrimaryMasterKey string = listKeys(cosmosDbName_resource.id, '2022-02-15-preview').primaryMasterKey