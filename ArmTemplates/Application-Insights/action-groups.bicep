param actionGroupName string
param emailAddress string = ''
param webHookUrl string = ''
param enabled bool = true

var hasValidActionToPerform = ((length(emailAddress) > 0) || (length(webHookUrl) > 0))
var baseProperties = {
  groupShortName: take(split(actionGroupName, '-')[2], 12)
  enabled: enabled
}
var emailPropertyArray = [
  {}
  {
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: emailAddress
        useCommonAlertSchema: true
      }
    ]
  }
]
var webhookPropertyArray = [
  {}
  {
    webhookReceivers: [
      {
        name: '${actionGroupName}-webhook'
        serviceUri: webHookUrl
      }
    ]
  }
]
var webHookPropertyEntry = (empty(webHookUrl) ? 0 : 1)
var emailPropertyEntry = (empty(emailAddress) ? 0 : 1)
var groupProperties = union(baseProperties, emailPropertyArray[emailPropertyEntry], webhookPropertyArray[webHookPropertyEntry])

resource actionGroupName_resource 'microsoft.insights/actionGroups@2019-06-01' = if (hasValidActionToPerform) {
  name: actionGroupName
  location: 'global'
  tags: {}
  properties: groupProperties
}

output Properties object = groupProperties