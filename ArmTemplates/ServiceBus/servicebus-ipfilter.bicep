@allowed([
  'Accept'
  'Reject'
])
param action string

@description('List of IP addresses allowed to connect to ServiceBus')
param ipAddress string

@description('Name of the namespace')
param servicebusName string

resource servicebusName_action_ipAddress 'Microsoft.ServiceBus/Namespaces/IPFilterRules@2018-01-01-preview' = {
  name: '${servicebusName}/${action}-${ipAddress}'
  properties: {
    filterName: '${servicebusName}/${action}-${ipAddress}'
    action: action
    ipMask: ipAddress
  }
}