@description('Name of an existing Service Bus namespace to add the topic to')
param serviceBusNamespaceName string

@description('Topic name to add to Service Bus')
param serviceBusTopicName string

@description('Subscription name to add to Service Bus')
param serviceBusTopicSubscriptionName string

@description('Optionally add a SQL filter rule if provided')
param subscriptionSqlFilter string = ''

var fullSBTopicSubscriptionName_var = '${serviceBusNamespaceName}/${serviceBusTopicName}/${serviceBusTopicSubscriptionName}'

resource fullSBTopicSubscriptionName 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-11-01' = {
  name: fullSBTopicSubscriptionName_var
  properties: {}
}

resource fullSBTopicSubscriptionName_serviceBusTopicName_sqlfilter 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-11-01' = if (length(subscriptionSqlFilter) > 0) {
  parent: fullSBTopicSubscriptionName
  name: '${serviceBusTopicName}-sqlfilter'
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: subscriptionSqlFilter
    }
  }
  dependsOn: [
    serviceBusTopicSubscriptionName
  ]
}