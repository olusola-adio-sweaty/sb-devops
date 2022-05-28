@description('Name of azure maps')
param azureMapsName string

@description('The name of the SKU, in standard format (S0 or S1).')
param azureMapsSkuName string = 'S0'

resource azureMapsName_resource 'Microsoft.Maps/accounts@2021-12-01-preview' = {
  name: azureMapsName
  location: 'global'
  sku: {
    name: azureMapsSkuName
  }
}