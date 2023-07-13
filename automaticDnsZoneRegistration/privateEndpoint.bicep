@description('Required. Name of the private endpoint resource to create.')
param parPrivateEndpointName string

@description('Resource ID of the subnet where the endpoint needs to be created.')
param parSubnetResourceId string

@description('Required. Resource ID of the resource that needs to be connected to the network.')
param parServiceResourceId string

@description('Required. Subtype(s) of the connection to be created (e.g.: vault). The allowed values depend on the type serviceResourceId refers to.')
param parGroupIds array

@description('Optional. Location for all Resources. Default: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('Optional. Tags to be applied on all resources/resource groups in this deployment. Default: Empty Object')
param parTags object = {}

resource resPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: parPrivateEndpointName
  location: parLocation
  tags: parTags
  properties: {
    privateLinkServiceConnections: [
      {
        name: parPrivateEndpointName
        properties: {
          privateLinkServiceId: parServiceResourceId
          groupIds: parGroupIds
        }
      }
    ]
    customNetworkInterfaceName: '${parPrivateEndpointName}-nic'
    subnet: {
      id: parSubnetResourceId
    }
  }
}

@description('The resource group the private endpoint was deployed into.')
output outResourceGroupName string = resourceGroup().name

@description('The resource ID of the private endpoint.')
output outResourceId string = resPrivateEndpoint.id

@description('The name of the private endpoint.')
output outPrivateEndpointName string = resPrivateEndpoint.name

@description('The private IP-address created.')
output outPrivateIPv4Address string = resPrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]

@description('The location the resource was deployed into.')
output outLocation string = resPrivateEndpoint.location
