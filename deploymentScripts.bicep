param parLocation string = 'westeurope'

var varTenantId = tenant().tenantId

resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'my-managed-identity'
  location: parLocation
}

resource resDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'create-spn-for-kv'
  location: parLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resManagedIdentity.id}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '9.0'
    retentionInterval: 'P1D'
    scriptContent: '''
      $spnAppId = New-AzADServicePrincipal -DisplayName "my-keyvault-spn" | Select-Object -ExpandProperty AppId
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['appId'] = $spnAppId
    '''
  }
}

resource resKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'my-ds-key-vault'
  location: parLocation
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: varTenantId
    accessPolicies: [
      {
        tenantId: varTenantId
        objectId: resDeploymentScript.properties.outputs.appId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
