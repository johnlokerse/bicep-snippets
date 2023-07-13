@description('The name of the Key Vault.')
@maxLength(24)
param parKeyVaultName string

@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parRegion string = resourceGroup().location

@description('Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Azure Key Vault. Default: true')
param parEnabledForDeployment bool = true

@description('Whether Azure Disk Encryption is permitted to retrieve secrets from the Azure Key Vault and unwrap keys. Default: true')
param parEnabledForDiskEncryption bool = true

@description('Whether Azure Resource Manager is permitted to retrieve secrets from the Azure Key Vault and unwrap keys. Default: true')
param parEnabledForTemplateDeployment bool = true

@description('Whether Purge protection is enabled on the Azure Key Vault. This a recommended practice in Production environments. Default: true')
param parEnablePurgeProtection bool = true

@description('Whether the Azure Key Vault will use Role Based Access Control (RBAC) for the authorization of data actions, and the Access Policies specified will be ignored. Since this is a preview feature, it is not recommended to use for now. Default: false')
param parEnableRbacAuthorization bool = false

@description('Whether Soft Delete is enabled on the Azure Key Vault. This a recommended practice in Production environments. Default: true')
param parEnableSoftDelete bool = true

@description('Whether trusted Microsoft services can bypass the network rules on the Azure Key Vault. This a recommended practice for communication between PaaS services. Default: AzureServices')
param parBypass string = 'AzureServices'

@description('Whether the Azure Key Vault is protected by network rules. This a recommended practice for any Azure Key Vault. Default: Deny')
param parDefaultAction string = 'Deny'

@description('The source IP addresses or address ranges that can connect to the Azure Key Vault on a networking level. Default: Empty Array')
param parIPRules array = []

@description('Whether the Azure Key Vault will accept traffic from public internet. If you are planning to use Private Endpoints, disabling public access is a recommended practice. Otherwise, you should rely on IP-based filtering or Service Endpoints. Default: enabled')
param parPublicNetworkAccess string = 'enabled'

@description('The SKU name of the Azure Key Key Vault. In Production environments, it is recommended to use the Premium SKU whereas in other environments, the Standard SKU suffices. Default: premium')
param parSKUName string = 'premium'

@description('The number of days your Soft Delete copy is retained. In Production environments, it is recommended to set this to the maximum of 90 days. Default: 90')
param parSoftDeleteRetentionInDays int = 90

@description('The Id of the Azure Active Directory Tenant in which the Azure Key Vault is deployed.')
param parTenantId string = tenant().tenantId

@description('The array of policies to define the access for Azure Key Vault.')
param parAccessPolicies array = []

@description('A switch to enable private link. Default: false')
param parEnablePrivateLink bool = false

@description('An object that contains the information regarding private DNS registration and private link. Default: Object with required properties')
param parConnectivityObject object = {
  subscriptionId: '#{hubSubscriptionId}#'
  privateDnsResourceGroup: '#{PrivateDNSZones.ResourceGroupName}#'
  privateLinkResourceGroup: '#{PrivateLink.ResourceGroupName}#'
  targetSubnetResourceId: '#{targetSubnetResourceId}#'
}

var varKeyVaultDnsZoneTypes = [
  'vault'
  'vaultcore'
]

module modAzureKeyVault './keyVault.bicep' = {
  name: 'module-keyvault-${parKeyVaultName}'
  params: {
    parName: parKeyVaultName
    parRegion: parRegion
    parSecret: 'my-secret-value'
    parProperties: {
      enabledForDeployment: parEnabledForDeployment
      enabledForDiskEncryption: parEnabledForDiskEncryption
      enabledForTemplateDeployment: parEnabledForTemplateDeployment
      enablePurgeProtection: parEnablePurgeProtection
      enableRbacAuthorization: parEnableRbacAuthorization
      enableSoftDelete: parEnableSoftDelete
      networkAcls: {
        bypass: parBypass
        defaultAction: parDefaultAction
        ipRules: parIPRules
      }
      publicNetworkAccess: parPublicNetworkAccess
      sku: {
        family: 'A'
        name: parSKUName
      }
      softDeleteRetentionInDays: parSoftDeleteRetentionInDays
      tenantId: parTenantId
      accessPolicies: parAccessPolicies
    }
  }
}

module modPrivateLink './privateEndpoint.bicep' = if (parEnablePrivateLink) {
  name: 'deploy-privatelink-${parKeyVaultName}'
  scope: resourceGroup(parConnectivityObject.subscriptionId, parConnectivityObject.privateLinkResourceGroup) // Use a scope if you want to deploy the private endpoint in a different resource group
  params: {
    parPrivateEndpointName: parKeyVaultName
    parLocation: parRegion
    parGroupIds: [
      'vault'
    ]
    parServiceResourceId: modAzureKeyVault.outputs.outAzureKeyVaultId
    parSubnetResourceId: parConnectivityObject.targetSubnetResourceId
  }
}

module modDnsRecordRegistration './privateDnsZoneARecord.bicep' = [for dnsZoneType in varKeyVaultDnsZoneTypes: if (parEnablePrivateLink) {
  name: 'deploy-a-record-in-${dnsZoneType}-${parKeyVaultName}'
  scope: resourceGroup(parConnectivityObject.subscriptionId, parConnectivityObject.privateDnsResourceGroup) // Use a scope if you want to deploy the A record in a different resource group
  params: {
    parDnsZoneName: 'privatelink.${dnsZoneType}.azure.net'
    parDnsARecordName: parKeyVaultName
    // Make sure to include the condition below to avoid errors when private link is disabled to avoid DeployIfNotExists errors!
    parIPv4Address: parEnablePrivateLink ? modPrivateLink.outputs.outPrivateIPv4Address : ''
  }
}]
