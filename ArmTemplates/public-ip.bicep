@description('Name of the public IP address resource')
param ipAddressName string

@description('Public IP address SKU')
@allowed([
  'Basic'
  'Standard'
])
param ipAddressSku string = 'Basic'

@description('application gateway back end protocol')
@allowed([
  'Static'
  'Dynamic'
])
param allocationMethod string = 'Dynamic'

@description('Optionally set a DNS label on public IP address')
param publicDnsLabel string = ''
param location string = resourceGroup().location

var publicIPAddressProperties = {
  withDnsLabel: {
    publicIPAllocationMethod: allocationMethod
    dnsSettings: {
      domainNameLabel: publicDnsLabel
    }
  }
  withoutDnsLabel: {
    publicIPAllocationMethod: allocationMethod
  }
}

resource ipAddressName_resource 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: ipAddressName
  location: location
  sku: {
    name: ipAddressSku
  }
  properties: ((length(publicDnsLabel) == 0) ? publicIPAddressProperties.withoutDnsLabel : publicIPAddressProperties.withDnsLabel)
}

output publicIpAddressId string = ipAddressName_resource.id