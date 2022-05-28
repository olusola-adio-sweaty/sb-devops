@description('Name of the storage account')
param storageAccountName string

@description('Name of the storage container')
@minLength(3)
@maxLength(63)
param storageContainerName string

@description('Specifies whether data in the container may be accessed publicly and the level of access.  Defaults to None.')
@allowed([
  'Container'
  'Blob'
  'None'
])
param publicAccess string = 'None'

var ContainerName_var = toLower('${storageAccountName}/default/${storageContainerName}')

resource ContainerName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: ContainerName_var
  properties: {
    publicAccess: publicAccess
  }
}