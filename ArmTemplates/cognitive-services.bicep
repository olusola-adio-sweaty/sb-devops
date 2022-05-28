@description('Name of service')
param cognitiveServiceName string

@description('The type of service you want to create')
@allowed([
  'Bing.Autosuggest.v7'
  'Bing.CustomSearch'
  'Bing.EntitySearch'
  'Bing.Search.v7'
  'Bing.SpellCheck.v7'
  'CognitiveServices'
  'ComputerVision'
  'ContentModerator'
  'CustomVision.Prediction'
  'CustomVision.Training'
  'Face'
  'Internal.AllInOne'
  'LUIS'
  'QnAMaker'
  'SpeakerRecognition'
  'SpeechServices'
  'TextAnalytics'
  'TextTranslation'
])
param cognitiveServiceType string

@description('SKU for Service')
@allowed([
  'F0'
  'S1'
  'S2'
  'S3'
  'S4'
])
param cognitiveServiceSku string = 'S1'
param location string = resourceGroup().location

var location_var = ((startsWith(cognitiveServiceType, 'Bing') || (cognitiveServiceType == 'TextTranslation')) ? 'global' : location)

resource cognitiveServiceName_resource 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: cognitiveServiceName
  location: location_var
  kind: cognitiveServiceType
  sku: {
    name: cognitiveServiceSku
  }
  properties: {}
}

#disable-next-line outputs-should-not-contain-secrets
output cognitiveServicePrimaryKey string = listKeys(cognitiveServiceName_resource.id, '2022-03-01').key1
