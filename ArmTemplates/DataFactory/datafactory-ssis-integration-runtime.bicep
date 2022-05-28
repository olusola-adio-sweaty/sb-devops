@description('Name of the data factory. Must be globally unique.')
param DataFactoryName string

@description('Name for the integration runtime')
param RuntimeName string

@description('Description of the integration runtime')
param RuntimeDescription string

@description('Size of the integration runtime node')
param NodeSize string

@description('Number of nodes to run the integration runtime upon')
param NodeCount int = 2

@description('Maximum number of concurrent jobs per node')
param MaxConcurrentJobsPerNode int = 8

@description('Endpoint of the server containing the SSIS catalog.')
param CatalogServerEndpoint string

@description('Username to access the SSIS catalog.')
param CatalogServerAdminUsername string

@description('Password to access the SSIS catalog.')
@secure()
param CatalogServerAdminPassword string
param location string = resourceGroup().location

resource DataFactoryName_RuntimeName 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${DataFactoryName}/${RuntimeName}'
  properties: {
    type: 'Managed'
    description: RuntimeDescription
    typeProperties: {
      computeProperties: {
        location: location
        nodeSize: NodeSize
        numberOfNodes: NodeCount
        maxParallelExecutionsPerNode: MaxConcurrentJobsPerNode
      }
      ssisProperties: {
        catalogInfo: {
          catalogServerEndpoint: CatalogServerEndpoint
          catalogAdminUserName: CatalogServerAdminUsername
          catalogAdminPassword: {
            type: 'SecureString'
            value: CatalogServerAdminPassword
          }
          catalogPricingTier: null
        }
        edition: 'Standard'
        licenseType: 'LicenseIncluded'
      }
    }
  }
}