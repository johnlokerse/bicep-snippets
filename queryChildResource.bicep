resource resVnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'my-vnet'

  resource resChildSubnet 'subnets' existing = {
    name: 'my-subnet'
  }
}

// query child resource
output outChildSubnetId string = resVnet::resChildSubnet.id
