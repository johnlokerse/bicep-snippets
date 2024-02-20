param parLocation string = 'westeurope'

resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'my-managed-identity'
  location: parLocation
}

resource resStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'privatedeploymentscripts'
  kind: 'StorageV2'
  location: parLocation
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource resPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
   name: resStorageAccount.name
   location: parLocation
   properties: {
    privateLinkServiceConnections: [
      {
        name: resStorageAccount.name
        properties: {
          privateLinkServiceId: resStorageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    customNetworkInterfaceName: '${resStorageAccount.name}-nic'
    subnet: {
      id: resVirtualNetwork::resPrivateEndpointSubnet.id
    }
   }
}

resource resStorageFileDataPrivilegedContributorRef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource resRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resStorageFileDataPrivilegedContributorRef.id, resManagedIdentity.id, resStorageAccount.id)
  scope: resStorageAccount
  properties: {
    principalId: resManagedIdentity.properties.principalId
    roleDefinitionId: resStorageFileDataPrivilegedContributorRef.id
    principalType: 'ServicePrincipal'
  }
}

resource resPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.core.windows.net'
  location: 'global'

  resource resVirtualNetworkLink 'virtualNetworkLinks' = {
    name: uniqueString(resVirtualNetwork.name)
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: resVirtualNetwork.id
      }
    }
  }

  resource resRecord 'A' = {
    name: resStorageAccount.name
    properties: {
      ttl: 10
      aRecords: [
        {
          ipv4Address: first(first(resPrivateEndpoint.properties.customDnsConfigs)!.ipAddresses)
        }
      ]
    }
  }
}

resource resVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'my-vnet'
  location: parLocation
  properties:{
    addressSpace: {
      addressPrefixes: [
        '192.168.4.0/23'
      ]
    }
  }

  resource resPrivateEndpointSubnet 'subnets' = {
    name: 'PrivateEndpointSubnet'
    properties: {
      addressPrefixes: [
        '192.168.4.0/24'
      ]
    }
  }

  resource resContainerInstanceSubnet 'subnets' = {
    name: 'ContainerInstanceSubnet'
    properties: {
      addressPrefix: '192.168.5.0/24'
      delegations: [
        {
          name: 'containerDelegation'
          properties: {
            serviceName: 'Microsoft.ContainerInstance/containerGroups'
          }
        }
      ]
    }
  }
}

resource resPrivateDeploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'my-private-deployment-script'
  dependsOn: [
    resPrivateEndpoint
    resPrivateDnsZone::resVirtualNetworkLink
  ]
  location: parLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resManagedIdentity.id}' : {}
    }
  }
  properties: {
    storageAccountSettings: {
      storageAccountName: resStorageAccount.name
    }
    containerSettings: {
      subnetIds: [
        {
          id: resVirtualNetwork::resContainerInstanceSubnet.id
        }
      ]
    }
    azPowerShellVersion: '9.0'
    retentionInterval: 'P1D'
    scriptContent: 'Write-Host "Hello World!"'
  }
}
