@description('Name of the Authorization Rule (shared access policy)')
param authorizationRuleName string

@description('Queue to apply the rule (policy) to')
param queueName string

@description('Array of rights to be assigned to the rule.  Rights are limited to Manage, Send, Listen')
param rights array

@description('Name of Service Bus namespace the queue attached to')
param servicebusName string
param location string = resourceGroup().location

resource servicebusName_queueName_authorizationRuleName 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2021-11-01' = {
  name: '${servicebusName}/${queueName}/${authorizationRuleName}'
  location: location
  tags: {}
  properties: {
    rights: rights
  }
}