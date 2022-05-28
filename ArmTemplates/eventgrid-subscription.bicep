param eventgridTopicName string
param eventgridSubscriptionName string
param eventGridSubscriptionUrl string
param location string = resourceGroup().location

resource eventGridTopicName_Microsoft_EventGrid_eventGridSubscriptionName 'Microsoft.EventGrid/topics/providers/eventSubscriptions@2020-04-01-preview' = {
  name: '${eventgridTopicName}/Microsoft.EventGrid/${eventgridSubscriptionName}'
  location: location
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: eventGridSubscriptionUrl
      }
    }
    filter: {
      includedEventTypes: [
        'All'
      ]
    }
  }
}