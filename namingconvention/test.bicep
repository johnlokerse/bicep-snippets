module modNaming 'namingconvention.module.bicep' = {
  name: 'namingconvention'
  params: {
    parEnvironment: 'prod'
    parIndex: '001'
    parRegion: 'we'
    parResourceType: 'Microsoft.KeyVault/vaults'
    parWorkload: 'secret'
  }
}

output outTest string = modNaming.outputs.outCAFResourceName
