@minLength(5)
@maxLength(50)
param containerRegistryName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param containerRegistrySku string = 'Standard'
param location string = resourceGroup().location

resource containerRegistryName_resource 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  properties: {
    adminUserEnabled: true
  }
}

#disable-next-line outputs-should-not-contain-secrets
output registryCredential string = containerRegistryName_resource.listCredentials('2021-12-01-preview').passwords[0].value
