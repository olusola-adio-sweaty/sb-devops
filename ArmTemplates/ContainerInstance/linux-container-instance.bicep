param containerName string
param appContainerRegistryImage string

@secure()
param containerRegistryPassword string = ''
param containerRegistryServer string = 'hub.docker.com'
param containerRegistryUsername string = 'username'
param cpu int
param memoryInGb int

@allowed([
  'Private'
  'Public'
])
param ipAddressType string = 'Private'
param managedIdentity bool = false

@description('See documentation file linux-container-instance.md for information on how to correctly format this parameter.')
@secure()
param environmentVariables object = {
  
}
param mountedVolumeMountPath string = ''

@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Never'
param storageAccountToMount string = ''
param storageAccountFileShareName string = ''

@secure()
param storageAccountKey string = ''
param tcpPorts array = [
  0
]
param location string = resourceGroup().location

var GroupVolumes = {
  EmptyVolume: {
    name: 'novolume'
    emptyDir: {}
  }
  StorageAccountVolume: {
    name: StorageAccountMountedFileShareName
    azureFile: {
      readOnly: false
      shareName: storageAccountFileShareName
      storageAccountName: storageAccountToMount
      storageAccountKey: storageAccountKey
    }
  }
}
var IdentityProperties = (managedIdentity ? IdentityTypes.ManagedIdentity : IdentityTypes.NoIdentity)
var IdentityTypes = {
  ManagedIdentity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentityName.id}': {}
    }
  }
  NoIdentity: {
    type: 'None'
  }
}
var ImageRegistryCredentials = {
  withPassword: [
    {
      server: containerRegistryServer
      username: containerRegistryUsername
      password: containerRegistryPassword
    }
  ]
  withoutPassword: [
    {
      server: containerRegistryServer
      username: containerRegistryUsername
      password: 'not-a-real-password'
    }
  ]
}
var ManagedIdentityName_var = '${containerName}-umi'
var StorageAccountMountedFileShareName = 'fileshare-${storageAccountFileShareName}'
var VolumeMounts = {
  NoMountedVolume: []
  MountedFileShare: [
    {
      name: StorageAccountMountedFileShareName
      mountPath: mountedVolumeMountPath
      readOnly: false
    }
  ]
}
var TcpPorts_var = [for item in tcpPorts: {
  port: item
  protocol: 'TCP'
}]

resource containerName_resource 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: containerName
  location: location
  identity: IdentityProperties
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: appContainerRegistryImage
          ports: ((tcpPorts[0] == 0) ? [
            ''
          ] : TcpPorts_var)
          environmentVariables: environmentVariables.variables
          resources: {
            requests: {
              cpu: cpu
              memoryInGB: memoryInGb
            }
          }
          volumeMounts: ((mountedVolumeMountPath == '') ? VolumeMounts.NoMountedVolume : VolumeMounts.MountedFileShare)
        }
      }
    ]
    imageRegistryCredentials: ((containerRegistryPassword == '') ? ImageRegistryCredentials.withoutPassword : ImageRegistryCredentials.withPassword)
    ipAddress: {
      type: ipAddressType
      dnsNameLabel: containerName
      ports: ((tcpPorts[0] == 0) ? [
        ''
      ] : TcpPorts_var)
    }
    osType: 'Linux'
    restartPolicy: restartPolicy
    volumes: [
      ((storageAccountFileShareName == '') ? GroupVolumes.EmptyVolume : GroupVolumes.StorageAccountVolume)
    ]
  }
}

resource ManagedIdentityName 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = if (managedIdentity) {
  name: ManagedIdentityName_var
  location: location
}

output ManagedIdentityObjectId string = reference(ManagedIdentityName.id, '2021-09-30').principalId
