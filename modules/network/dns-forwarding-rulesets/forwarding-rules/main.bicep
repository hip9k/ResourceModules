@description('Required. Name of the Forwarding Rule.')
@minLength(1)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

@description('Conditional. Name of the parent DNS Forwarding Ruleset. Required if the template is used in a standalone deployment.')
param dnsForwardingRulesetName string

@description('Required. The domain name for the forwarding rule.')
param domainName string

@description('Optional. The state of forwarding rule.')
@allowed([
  'Disabled'
  'Enabled'
])
param forwardingRuleState string = 'Enabled'

@description('Optional. Metadata attached to the forwarding rule.')
param metadata object = {}

@description('Required. DNS servers to forward the DNS query to.')
param targetDnsServers array

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource dnsForwardingRuleset 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' existing = {
  name: dnsForwardingRulesetName
}

resource forwardingRule 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  name: name
  parent: dnsForwardingRuleset
  properties: {
    domainName: domainName
    forwardingRuleState: forwardingRuleState
    metadata: metadata
    targetDnsServers: targetDnsServers
  }
}

@description('The resource group the Forwarding Rule was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Forwarding Rule.')
output resourceId string = forwardingRule.id

@description('The name of the Forwarding Rule.')
output name string = forwardingRule.name
