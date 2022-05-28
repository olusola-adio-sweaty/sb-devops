@description('Name of the keyvault with the certificates')
param keyVaultName string

@description('Array of certificate names as they appear in the keyvault secret')
param certificates array

@description('Resource ID of the associated App Service plan')
param serverFarmId string = ''
param location string = resourceGroup().location

var keyVaultId = resourceId('Microsoft.KeyVault/vaults', keyVaultName)

resource certificates_resource 'Microsoft.Web/certificates@2020-12-01' = [for item in certificates: {
  name: item
  location: location
  properties: {
    keyVaultId: keyVaultId
    keyVaultSecretName: item
    serverFarmId: ((length(serverFarmId) > 0) ? serverFarmId : json('null'))
  }
}]