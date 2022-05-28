@description('Name of the keyvault with the certificates')
param keyVaultName string

@description('Name of secret which contains the certificate')
param keyVaultCertificateName string

@description('Resource group the App Service Plan is within')
param keyVaultResourceGroup string = resourceGroup().name

@description('Resource ID of the associated App Service plan')
param serverFarmId string = ''
param location string = resourceGroup().location

var includeServerFarmId = (length(serverFarmId) > 0)
var certificateResourceProperties = {
  withServerFarmId: {
    keyVaultId: resourceId(keyVaultResourceGroup, 'Microsoft.KeyVault/vaults', keyVaultName)
    keyVaultSecretName: keyVaultCertificateName
    serverFarmId: serverFarmId
  }
  withoutServerFarmId: {
    keyVaultId: resourceId(keyVaultResourceGroup, 'Microsoft.KeyVault/vaults', keyVaultName)
    keyVaultSecretName: keyVaultCertificateName
  }
}

resource keyVaultCertificateName_resource 'Microsoft.Web/certificates@2021-03-01' = {
  name: keyVaultCertificateName
  location: location
  properties: (includeServerFarmId ? certificateResourceProperties.withServerFarmId : certificateResourceProperties.withoutServerFarmId)
}

output certificateThumbprint string = reference(keyVaultCertificateName_resource.id, '2021-03-01').Thumbprint