@description('Name of the data factory. Must be globally unique.')
param DataFactoryName string

@description('Location of the data factory. Currently, only East US, East US 2, and West Europe are supported. ')
@allowed([
  'East US'
  'East US 2'
  'West Europe'
])
param DataFactoryLocation string = 'West Europe'

@description('The GitHub repo will first need to be configured from the Data Factory GUI so that Azure Data Factory can be added to the GitHub organisation as an authorized OAuth app.')
param GitHubAccountName string = ''

@description('The Azure DevOps organsation name, can be obtained from Organization settings > Overview.  The Azure DevOps organization will need to be connected to an AAD tenant.  This will remove access for all existing accounts.')
param VstsAccountName string = ''
param VstsProjectName string = ''

@description('The name of the GitHub or Azure DevOps git repo.  The repo will need to already exist and be initialized.')
param RepositoryName string = ''

var dataFactoryProperties = (((VstsAccountName == '') && (GitHubAccountName == '')) ? '' : ((VstsAccountName == '') ? githubRepoConfig : vstsRepoConfig))
var githubRepoConfig = {
  repoConfiguration: {
    accountName: GitHubAccountName
    repositoryName: RepositoryName
    hostName: ''
    collaborationBranch: 'master'
    rootFolder: '/'
    type: 'FactoryGitHubConfiguration'
    lastCommitId: ''
  }
}
var vstsRepoConfig = {
  repoConfiguration: {
    accountName: VstsAccountName
    repositoryName: RepositoryName
    projectName: VstsProjectName
    collaborationBranch: 'master'
    rootFolder: '/'
    type: 'FactoryVSTSConfiguration'
    lastCommitId: ''
  }
}

resource DataFactoryName_resource 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: DataFactoryName
  location: DataFactoryLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: dataFactoryProperties
}