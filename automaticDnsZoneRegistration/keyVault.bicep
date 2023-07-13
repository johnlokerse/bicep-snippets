@description('The name of the Key Vault.')
@maxLength(24)
param parName string

@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parRegion string = resourceGroup().location

@description('Tags you would like to be applied to all resources in this module. Default: empty object')
param parTags object = {}

@description('Properties of the Virtual Network Gateway to be deployed. Default: None')
param parProperties object = {}

@description('List of secrets to store in the created Key Vault.')
@secure()
param parSecret string = ''

resource resAzureKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: parName
  location: parRegion
  tags: parTags
  properties: parProperties
}

resource resSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = if (!empty(parSecret)) {
  name: 'my-secret'
  parent: resAzureKeyVault
  properties: {
    attributes: {
      enabled: true
    }
    value: parSecret
  }
}

output outAzureKeyVault object = resAzureKeyVault
output outAzureKeyVaultId string = resAzureKeyVault.id
output outAzureKeyVaultName string = resAzureKeyVault.name
