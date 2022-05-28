param apimServiceName string
param apiName string

@allowed([
  'Header'
  'Query'
  'Segment'
])
param versioningMethod string
param versionProperty string = ''

var lowerApiName = toLower(apiName)
var versionSetName = '${lowerApiName}-versionset'

resource ApimServiceName_VersionSetName 'Microsoft.ApiManagement/service/apiVersionSets@2019-01-01' = {
  name: '${apimServiceName}/${versionSetName}'
  properties: {
    displayName: lowerApiName
    versioningScheme: versioningMethod
    description: 'The ${lowerApiName} version set'
    versionHeaderName: versionProperty
    versionQueryName: versionProperty
  }
}