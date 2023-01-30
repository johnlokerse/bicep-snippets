param parResourceType string
param parIndex string
param parRegion string
param parWorkload string
param parEnvironment string

var varResourceType = [
  {
    type: 'Microsoft.Network/azureFirewalls'
    shortName: 'afw'
  }
  {
    type: 'Microsoft.Network/virtualNetworks'
    shortName: 'vnet'
  }
  {
    type: 'Microsoft.Network/virtualNetworkGateways'
    shortName: 'vng'
  }
  {
    type: 'Microsoft.Network/routeTables'
    shortName: 'rt'
  }
  {
    type: 'Microsoft.KeyVault/vaults'
    shortName: 'kv'
  }
]

var varSelectedResourceType = first(filter(varResourceType, resourceType => resourceType.type == parResourceType))

output outCAFResourceName string = '${varSelectedResourceType.shortName}}-${parWorkload}-${parEnvironment}-${parRegion}-${padLeft(parIndex, 3, '0')}'
