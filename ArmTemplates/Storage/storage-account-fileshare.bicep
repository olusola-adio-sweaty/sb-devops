@description('Name of the file share')
param fileShareName string

@description('Name of the storage account')
param storageAccountName string

var FileShareName_var = toLower('${storageAccountName}/default/${fileShareName}')

resource FileShareName_resource 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: FileShareName_var
  properties: {}
}