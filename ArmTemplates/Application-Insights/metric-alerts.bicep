param enabled bool = true
param alertName string

@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 3
param metricName string

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'Equals'
  'NotEquals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'GreaterThan'

@description('an array of objects (containing name, operator, and values) that represent the dimensions to attach to the metric alert.')
param dimensions array = []

@description('The threshold value at which the alert is activated.')
param threshold string = '0'

@description('How the data that is collected should be combined over time.')
@allowed([
  'Average'
  'Minimum'
  'Maximum'
  'Total'
  'Count'
])
param aggregation string = 'Average'

@description('Period of time used to monitor alert activity based on the threshold. Must be between five minutes and one day. ISO 8601 duration format.')
param windowSize string = 'PT5M'

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
param evaluationFrequency string = 'PT1M'
param actionGroupName string

@description('The name of the resource containing the action group. Leave empty for the same resource group.')
param actionGroupResourceGroup string = ''

@description('The id of the resource to attach the alert to')
param resourceId string

var actionGroupResourceGroup_var = (empty(actionGroupResourceGroup) ? resourceGroup().name : actionGroupResourceGroup)

resource alertName_resource 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  tags: {}
  properties: {
    description: 'Alert for metric ${metricName}'
    severity: alertSeverity
    enabled: enabled
    scopes: [
      resourceId
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'metric critria'
          metricName: metricName
          dimensions: dimensions
          operator: operator
          threshold: threshold
          timeAggregation: aggregation
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: subscriptionResourceId(actionGroupResourceGroup_var, 'microsoft.insights/actionGroups', actionGroupName)
      }
    ]
  }
}
