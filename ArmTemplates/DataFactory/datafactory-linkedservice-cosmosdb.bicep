param CosmosDbName string

@secure()
param CosmosDbPrimaryKey string
param CosmosDbDatabases array

@description('Name of the data factory. Must be globally unique.')
param DataFactoryName string

var cosmosDbPartialConnectionString = 'AccountEndpoint=https://${CosmosDbName}.documents.azure.com:443/;AccountKey=${CosmosDbPrimaryKey}'

resource DataFactoryName_CosmosDbReadOnly_CosmosDbDatabases 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = [for item in CosmosDbDatabases: {
  name: '${DataFactoryName}/CosmosDbReadOnly_${item}'
  properties: {
    type: 'CosmosDb'
    description: 'Azure CosmosDb linked service'
    typeProperties: {
      connectionString: {
        value: '${cosmosDbPartialConnectionString};Database=${item};'
        type: 'SecureString'
      }
    }
  }
}]