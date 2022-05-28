@description('Name of the SQL Server Managed Instance')
param msqlServerName string

@description('Name of new Azure VNet where you can deploy Azure Sql Managed Instances and the resources that use them')
param msqlSubnetId string

@description('The Azure SQL Server Administrator (SA) username. A generated name will be used if not supplied.')
param sqlServerAdminUserName string = ''

@description('The Azure SQL Server Administrator (SA) password')
@secure()
param sqlServerAdminPassword string

@description('The active directory admin or group name that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminLogin string

@description('The object id of the active directory admin that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminObjectId string

@description('Number of vCores')
param vCores int = 8

@description('Storage limit for the database in GB')
param storageSizeGb int = 128

@description('Control whether the public endopint is available or not.')
param publicDataEndpointEnabled bool = false
param location string = resourceGroup().location

var sqlServerAdminUserName_var = ((sqlServerAdminUserName == '') ? uniqueString(resourceGroup().id) : sqlServerAdminUserName)

resource msqlServerName_resource 'Microsoft.Sql/managedInstances@2021-11-01-preview' = {
  name: msqlServerName
  location: location
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: vCores
  }
  properties: {
    administratorLogin: sqlServerAdminUserName_var
    administratorLoginPassword: sqlServerAdminPassword
    subnetId: msqlSubnetId
    vCores: vCores
    storageSizeInGB: storageSizeGb
    publicDataEndpointEnabled: publicDataEndpointEnabled
  }
}

resource msqlServerName_activeDirectory 'Microsoft.Sql/managedInstances/administrators@2021-11-01-preview' = {
  parent: msqlServerName_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlServerActiveDirectoryAdminLogin
    sid: sqlServerActiveDirectoryAdminObjectId
    tenantId: subscription().tenantId
  }
}

output saAdministratorLogin string = sqlServerAdminUserName_var
output fullyQualifiedDomainName string = msqlServerName_resource.properties.fullyQualifiedDomainName