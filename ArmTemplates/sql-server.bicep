@description('Name of the Azure SQL Server  instance')
param sqlServerName string

@description('The Azure SQL Server Administrator (SA) username. A generated name will be used if not supplied.')
param sqlServerAdminUserName string = ''

@description('The Azure SQL Server Administrator (SA) password')
@secure()
param sqlServerAdminPassword string

@description('Name of the SQL logs storage account for the environment')
param storageAccountName string

@description('The active directory admin or group name that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminLogin string

@description('The object id of the active directory admin that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminObjectId string

@description('The email address(es) that threat alerts will be sent to (no alerts will be configured if no email address provided)')
param threatDetectionEmailAddress array = []

@description('Name of the elastic pool to create (does not create one if no name passed)')
param elasticPoolName string = ''

@description('The edition component of the sku (defaultValues to Standard)')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'GeneralPurpose'
  'BusinessCritical'
])
param elasticPoolEdition string = 'Standard'

@description('Total DTU assigned to elastic pool')
param elasticPoolTotalDTU int = 100

@description('Minimum DTU for each databases (reserved)')
param elasticPoolMinDTU int = 0

@description('Storage limit for the database elastic pool in MB')
param elasticPoolStorage int = 51200
param location string = resourceGroup().location

var elasticPoolName_var = ((elasticPoolName == '') ? '${sqlServerName}/${sqlServerName}' : '${sqlServerName}/${elasticPoolName}')
var sqlServerAdminUserName_var = ((sqlServerAdminUserName == '') ? uniqueString(resourceGroup().id) : sqlServerAdminUserName)
var auditPolicyName = '${sqlServerName}-DefaultAuditPolicy'
var securityAlertPolicyName = '${sqlServerName}-DefaultSecurityAlert'
var threatDetectionEmailAddress_var = array('["dummy@example.com]"]')
var activeDirectoryYesNo = ((elasticPoolName != '') ? 'Microsoft.Sql/servers/${sqlServerName}/elasticPools/${elasticPoolName}' : 'Microsoft.Sql/servers/${sqlServerName}')

resource sqlServerName_resource 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdminUserName_var
    administratorLoginPassword: sqlServerAdminPassword
    minimalTlsVersion: '1.2'
  }
}

resource sqlServerName_AuditPolicyName 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = {
  parent: sqlServerName_resource
  name: '${auditPolicyName}'
  properties: {
    state: 'Enabled'
    storageEndpoint: 'https://${storageAccountName}.blob.core.windows.net/'
    storageAccountAccessKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value
    retentionDays: 90
  }
}

resource sqlServerName_SecurityAlertPolicyName 'Microsoft.Sql/servers/securityAlertPolicies@2021-11-01-preview' = if (threatDetectionEmailAddress != '') {
  parent: sqlServerName_resource
  name: '${securityAlertPolicyName}'
  properties: {
    state: ((length(threatDetectionEmailAddress) == 0) ? 'Disabled' : 'Enabled')
    emailAddresses: ((length(threatDetectionEmailAddress) == 0) ? threatDetectionEmailAddress_var : threatDetectionEmailAddress)
    emailAccountAdmins: false
    storageEndpoint: 'https://${storageAccountName}.blob.core.windows.net/'
    storageAccountAccessKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value
    retentionDays: 90
  }
  dependsOn: [
    sqlServerName_AuditPolicyName
  ]
}

resource sqlServerName_activeDirectory 'Microsoft.Sql/servers/administrators@2021-11-01-preview' = {
  parent: sqlServerName_resource
  name: 'ActiveDirectory'
  location: location
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlServerActiveDirectoryAdminLogin
    sid: sqlServerActiveDirectoryAdminObjectId
    tenantId: subscription().tenantId
  }
  dependsOn: [
    activeDirectoryYesNo
  ]
}

resource elasticPoolName_resource 'Microsoft.Sql/servers/elasticPools@2021-11-01-preview' = if (elasticPoolName != '') {
  name: elasticPoolName_var
  location: location
  properties: {
    edition: elasticPoolEdition
    dtu: elasticPoolTotalDTU
    databaseDtuMin: elasticPoolMinDTU
    databaseDtuMax: elasticPoolTotalDTU
    storageMB: elasticPoolStorage
    zoneRedundant: false
  }
  dependsOn: [
    sqlServerName_resource
  ]
}

output saAdministratorLogin string = sqlServerAdminUserName_var
output sqlServerFqdn string = sqlServerName_resource.properties.fullyQualifiedDomainName