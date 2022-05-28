param apimServiceName string
param productDisplayName string

@description('An optional textual description of the product')
param productDescription string = ''

@description('An optional terms of use for the product')
param productTerms string = ''

@description('Adds the built in Developers group to the Access Control list of the Product')
param addDevelopers bool = false

@description('Adds the built in Guests group to the Access Control list.  This allows unauthenticated access to the APIs in this Product.')
param allowAnonymousAccess bool = false

var apimProductInstanceName = toLower(replace(productDisplayName, ' ', '-'))
var properties = {
  anonAccess: {
    subscriptionRequired: false
    state: 'published'
    displayName: productDisplayName
    description: productDescription
    terms: productTerms
  }
  controlledAccess: {
    subscriptionRequired: true
    approvalRequired: (!addDevelopers)
    subscriptionsLimit: 1
    state: 'published'
    displayName: productDisplayName
    description: productDescription
    terms: productTerms
  }
}

resource apimServiceName_apimProductInstanceName 'Microsoft.ApiManagement/service/products@2018-01-01' = {
  name: '${apimServiceName}/${apimProductInstanceName}'
  properties: (allowAnonymousAccess ? properties.anonAccess : properties.controlledAccess)
  dependsOn: []
}

resource apimServiceName_apimProductInstanceName_Developers 'Microsoft.ApiManagement/service/products/groups@2018-01-01' = if (addDevelopers) {
  parent: apimServiceName_apimProductInstanceName
  name: 'Developers'
}

resource apimServiceName_apimProductInstanceName_Guests 'Microsoft.ApiManagement/service/products/groups@2018-01-01' = if (allowAnonymousAccess) {
  parent: apimServiceName_apimProductInstanceName
  name: 'Guests'
}

output ApimProductInstanceName string = apimProductInstanceName