targetScope = 'subscription'

@description('The name of the diagnostic setting')
param settingName string = 'datadog-activity-logs-diagnostic-setting'

@description('Name of the Resource Group of the EventHub')
param resourceGroup string

@description('Name of EventHub namespace, which must be globally unique.')
param eventHubNamespace string

@description('Name of the EventHub to which the Activity logs will be sent.')
param eventHubName string = 'datadog-eventhub'

@description('number of functins and event hubs')
param copies int

var subscriptionId = subscription().subscriptionId
