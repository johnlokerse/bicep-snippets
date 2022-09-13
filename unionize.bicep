@description('Name of Network Security Group to create.')
param parNetworkSecurityGroupName string

@description('The Azure Region to deploy the resources into.')
param parRegion string

@description('Tags you would like to be applied to the Network Security Group resource. Default: Empty Object')
param parTags object

@description('Definition of rules for the Network Security Group. Default: Empty Array')
param parNetworkSecurityGroupRules array = []

@description('Set default rule to allow or deny internet access. Default: false')
param parAllowInternetAccess bool = false

var varNoInternetRule = [
  {
    name: 'DenyInternet'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      access: 'Deny'
      priority: 100
      direction: 'Outbound'
      sourcePortRanges: []
      destinationPortRanges: []
      sourceAddressPrefixes: []
      destinationAddressPrefixes: []
    }
  }
]

var varNsgRules = parAllowInternetAccess ? parNetworkSecurityGroupRules : union(parNetworkSecurityGroupRules, varNoInternetRule)

resource resNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: parNetworkSecurityGroupName
  location: parRegion
  tags: parTags
  properties: {
    securityRules: varNsgRules
  }
}

output outNetworkSecurityGroupId string = resNetworkSecurityGroup.id
