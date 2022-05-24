@description('Name of the keyvault')
param keyVaultName string
@description('Name of the resourcegroup')
param location string = resourceGroup().location

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2018-02-14' = {
  name: keyVaultName
  location: location
  tags: {}
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
  }
}

output KeyVaultUri string = keyVaultName_resource.properties.vaultUri
