param redisName string

@description('The pricing tier of the Redis Cache')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisSkuName string = 'Standard'

@description('The size of the new Azure Redis Cache instance')
@minValue(0)
@maxValue(6)
param redisCapacity int = 1
param location string = resourceGroup().location

var redisSkuFamily = ((redisSkuName == 'Premium') ? 'P' : 'C')

resource redisName_resource 'Microsoft.Cache/Redis@2021-06-01' = {
  name: redisName
  location: location
  properties: {
    sku: {
      name: redisSkuName
      family: redisSkuFamily
      capacity: redisCapacity
    }
    enableNonSslPort: false
  }
}

output redisConnectionString string = '${redisName_resource.properties.hostName}:${redisName_resource.properties.sslPort},password=${listkeys(redisName_resource.id, providers('Microsoft.Cache', 'redis').apiVersions[0]).primaryKey},ssl=True,abortConnect=False,syncTimeout=2000,allowAdmin=true'
output redisAltConnectionString string = '${listkeys(redisName_resource.id, providers('Microsoft.Cache', 'redis').apiVersions[0]).primaryKey}@${redisName_resource.properties.hostName}:${redisName_resource.properties.sslPort}?ssl=True'