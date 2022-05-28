@description('Name of the data factory. Must be globally unique.')
param DataFactoryName string
param SqlDatabaseName string
param SqlDatabaseServer string
param SqlDatabaseUserName string

@secure()
param SqlDatabaseUserPassword string

resource DataFactoryName_SqlReadWrite_SqlDatabaseName 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${DataFactoryName}/SqlReadWrite_${SqlDatabaseName}'
  properties: {
    type: 'AzureSqlDatabase'
    description: 'Azure SQL Database linked service'
    typeProperties: {
      connectionString: {
        value: 'integrated security=False;encrypt=True;connection timeout=30;data source=${SqlDatabaseServer};initial catalog=${SqlDatabaseName};user id=${SqlDatabaseUserName};password=${SqlDatabaseUserPassword}'
        type: 'SecureString'
      }
    }
  }
}