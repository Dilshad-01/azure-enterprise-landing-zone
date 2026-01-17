terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}
}

# Policy Definition: Require Private Endpoints for PaaS
resource "azurerm_policy_definition" "require_private_endpoints" {
  name         = "require-private-endpoints"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Private Endpoints for PaaS Services"
  description  = "This policy ensures that PaaS services use private endpoints"

  policy_rule = jsonencode({
    if = {
      field = "type"
      in = [
        "Microsoft.Storage/storageAccounts",
        "Microsoft.KeyVault/vaults",
        "Microsoft.Sql/servers",
        "Microsoft.Web/sites"
      ]
    }
    then = {
      effect = "auditIfNotExists"
      details = {
        type = "Microsoft.Network/privateEndpoints"
        existenceCondition = {
          field = "Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].state"
          equals = "Approved"
        }
      }
    }
  })
}

# Policy Definition: Enforce VNet Peering to Hub Only
resource "azurerm_policy_definition" "enforce_hub_peering" {
  name         = "enforce-hub-peering"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce VNet Peering to Hub Only"
  description  = "This policy ensures that VNet peerings are only established with the hub network"

  parameters = jsonencode({
    hubVnetId = {
      type = "String"
      metadata = {
        displayName = "Hub Virtual Network ID"
        description = "The resource ID of the hub virtual network"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings"
        },
        {
          field = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/remoteVirtualNetwork.id"
          notEquals = "[parameters('hubVnetId')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require Route Table on Subnets
resource "azurerm_policy_definition" "require_route_table" {
  name         = "require-route-table"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Route Table on Subnets"
  description  = "This policy ensures that all subnets have a route table for traffic routing through the hub"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Network/virtualNetworks/subnets"
        },
        {
          field = "name"
          notIn = ["AzureFirewallSubnet", "AzureBastionSubnet", "GatewaySubnet"]
        },
        {
          field = "Microsoft.Network/virtualNetworks/subnets/routeTable.id"
          exists = false
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

