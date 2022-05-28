@description('Name of keyvault to add permissions to')
param keyVaultName string

@description('ObjectId of the ServicePrincipal')
param servicePrincipalObjectId string
param keyPermissions array = []
param secretPermissions array = [
  'get'
]
param certificatePermissions array = []
param storagePermissions array = []

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: servicePrincipalObjectId
        permissions: {
          keys: keyPermissions
          secrets: secretPermissions
          certificates: certificatePermissions
          storage: storagePermissions
        }
      }
    ]
  }
}