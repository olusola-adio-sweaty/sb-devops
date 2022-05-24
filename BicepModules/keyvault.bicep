@description('Name of the keyvault')
param keyVaultName string
@description('Name of the resourcegroup')
param location string = resourceGroup().location

var keyVault = {
  name: keyVaultName
  location: location
  sku_family: 'A'
  sku_name: 'standard'
  tenantId: subscription().tenantId
}

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVault.name
  location: keyVault.location
  tags: {}
  properties: {
    sku: {
      family: keyVault.sku_family
      name: keyVault.sku_name
    }
    tenantId: keyVault.tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
  }
}

output KeyVaultUri string = kv.properties.vaultUri
