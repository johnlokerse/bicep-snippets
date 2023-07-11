resource resKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'my-key-vault'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenant().tenantId
  }
}

resource resKeyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'bla'
  scope: resKeyVault
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: '<LogAnalyticsWorkspaceId>'
  }
}
