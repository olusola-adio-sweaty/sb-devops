@description('Name of the Authorization Rule (shared access policy)')
param authorizationRuleName string

@description('Topic to apply the rule (policy) to')
param topicName string

@description('Array of rights to be assigned to the rule.  Rights are limited to Manage, Send, Listen')
param rights array

@description('Name of Service Bus namespace the topic attached to')
param servicebusName string
param location string = resourceGroup().location

resource servicebusName_topicName_authorizationRuleName 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' = {
  name: '${servicebusName}/${topicName}/${authorizationRuleName}'
  location: location
  tags: {}
  properties: {
    rights: rights
  }
}