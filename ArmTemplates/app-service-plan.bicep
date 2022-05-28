@description('Name of the App Service Plan')
param appServicePlanName string

@description('Underlying server type for app service plan. If aseHostingEnvironmentName is specified, this will be Isolated and the value here ignored.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'PremiumV2'
])
param nonASETier string = 'Standard'

@description('Server size per instance (small, medium, large)')
@allowed([
  '1'
  '2'
  '3'
])
param aspSize string = '1'

@description('Scale out value; the number of instances in the plan')
@minValue(1)
@maxValue(20)
param aspInstances int = 1

@description('Optional App Service Environment for the app service to exist within. If not supplied creates a stand alone app service plan.')
param aseHostingEnvironmentName string = ''

@description('Resource group the App Service Environment belongs to - only required if aseHostingEnvironmentName specified')
param aseResourceGroup string = ''
param location string = resourceGroup().location

var deployToASE = (length(aseHostingEnvironmentName) > 0)
var v2Instance = ((nonASETier == 'PremiumV2') ? 'V2' : '')
var aspResourceProperties = {
  WithASE: {
    name: appServicePlanName
    hostingEnvironmentProfile: {
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${aseResourceGroup}/providers/Microsoft.Web/hostingEnvironments/${aseHostingEnvironmentName}'
    }
  }
  WithoutASE: {
    name: appServicePlanName
  }
}
var defaultAppServicePlanSKUs = {
  NonASE: {
    name: '${take(nonASETier, 1)}${aspSize}${v2Instance}'
    tier: nonASETier
    size: '${take(nonASETier, 1)}${aspSize}${v2Instance}'
    family: take(nonASETier, 1)
    capacity: aspInstances
  }
  Isolated: {
    name: 'I${aspSize}'
    tier: 'Isolated'
    size: 'I${aspSize}'
    family: 'I'
    capacity: aspInstances
  }
}

resource appServicePlanName_resource 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  sku: (deployToASE ? defaultAppServicePlanSKUs.Isolated : defaultAppServicePlanSKUs.NonASE)
  properties: (deployToASE ? aspResourceProperties.WithASE : aspResourceProperties.WithoutASE)
}

output appServicePlanId string = appServicePlanName_resource.id
