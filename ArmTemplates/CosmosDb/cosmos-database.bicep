@description('Name of the cosmosdb account')
param accountName string

@description('Name of the database to create on the cosmosdb account')
param databaseName string

@description('Provisions all the collections to use the shared RU of the database. Database requires at least 100RU per collection')
param useSharedRequestUnits bool = false

@description('When \'useSharedRequestUnits\' is set,  sets the databases Request Units.  The minimum assignment is 100 RUs per collection.  RUs must be assigned in increments of 100.')
param offerThroughput int = 400

@description('Set to true when the database needs creating. Works around ARM limitation.')
param databaseNeedsCreation bool = false

var DefaultDatabaseProperties = {
  resource: {
    id: databaseName
  }
}
var DatabaseThroughputCreationOption = [
  {}
  {
    options: {
      throughput: offerThroughput
    }
  }
]
var DatabasePropertyOption = int(((useSharedRequestUnits && databaseNeedsCreation) ? 1 : 0))
var DatabaseProperties = union(DefaultDatabaseProperties, DatabaseThroughputCreationOption[DatabasePropertyOption])

resource accountName_sql_databaseName 'Microsoft.DocumentDB/databaseAccounts/apis/databases@2015-04-08' = {
  name: '${accountName}/sql/${databaseName}'
  properties: DatabaseProperties
}

resource accountName_sql_databaseName_throughput 'Microsoft.DocumentDB/databaseAccounts/apis/databases/settings@2016-03-31' = if (useSharedRequestUnits) {
  parent: accountName_sql_databaseName
  name: 'throughput'
  properties: {
    resource: {
      throughput: offerThroughput
    }
  }
}
