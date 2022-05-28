@description('The name of the failure anomaly alert rule')
param alertName string

@description('When true, enable the processing of the alert. Otherwise, the alert will be paused.')
param enabled bool = true

@description('The severity of the alert')
param severity string = '2'

@description('The frequency the alert is processed in ISO 8601 duration format')
param frequency string = 'PT1M'

@description('The resource id of the app insights instance to attach the rule to')
param resourceId string

@description('The action group to trigger when the alert is fired')
param actionGroupId string

resource Failure_Anomalies_v2_alertName 'Microsoft.AlertsManagement/smartdetectoralertrules@2021-04-01' = {
  location: 'global'
  name: 'Failure Anomalies v2 - ${alertName}'
  properties: {
    description: 'Detects a spike in the failure rate of requests or dependencies'
    state: (enabled ? 'Enabled' : 'Disabled')
    severity: severity
    frequency: frequency
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      resourceId
    ]
    actionGroups: {
      groupIds: [
        actionGroupId
      ]
    }
  }
}