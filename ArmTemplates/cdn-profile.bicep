@description('Name of Content Delivery Network (CDN) profile')
param cdnProfileName string

@allowed([
  'Premium_Verizon'
  'Custom_Verizon'
  'Standard_Verizon'
  'Standard_Akamai'
  'Standard_Microsoft'
])
param cdnSKU string = 'Standard_Verizon'
param location string = resourceGroup().location

resource cdnProfileName_resource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: cdnProfileName
  location: location
  tags: {}
  sku: {
    name: cdnSKU
  }
}