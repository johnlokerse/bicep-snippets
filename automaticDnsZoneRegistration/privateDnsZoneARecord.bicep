@description('Name of the Private DNS Zone (Parent).')
param parDnsZoneName string

@description('Name of the A Record (Child).')
param parDnsARecordName string

@description('IPv4 Address to be coupled with the record name.')
param parIPv4Address string

resource resPrivateDnsZoneRef 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: parDnsZoneName
}

resource resDnsARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: parDnsARecordName
  parent: resPrivateDnsZoneRef
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: parIPv4Address
      }
    ]
  }
}
