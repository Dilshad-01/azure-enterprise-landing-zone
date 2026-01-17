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

# Custom Role: Platform Administrator
resource "azurerm_role_definition" "platform_administrator" {
  name        = "Platform Administrator"
  scope       = var.scope
  description = "Custom role for platform administrators with full control over hub subscription"

  permissions {
    actions = [
      "Microsoft.*/read",
      "Microsoft.Network/*",
      "Microsoft.Compute/*",
      "Microsoft.Storage/*",
      "Microsoft.KeyVault/*",
      "Microsoft.OperationalInsights/*",
      "Microsoft.Resources/*"
    ]
    not_actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleDefinitions/write"
    ]
  }

  assignable_scopes = [var.scope]
}

# Custom Role: Network Administrator
resource "azurerm_role_definition" "network_administrator" {
  name        = "Network Administrator"
  scope       = var.scope
  description = "Custom role for network administrators with network resource management permissions"

  permissions {
    actions = [
      "Microsoft.Network/*/read",
      "Microsoft.Network/virtualNetworks/*",
      "Microsoft.Network/networkSecurityGroups/*",
      "Microsoft.Network/routeTables/*",
      "Microsoft.Network/virtualNetworkPeerings/*",
      "Microsoft.Network/publicIPAddresses/*",
      "Microsoft.Network/loadBalancers/*",
      "Microsoft.Network/applicationGateways/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = [
      "Microsoft.Network/azureFirewalls/*",
      "Microsoft.Network/virtualNetworkGateways/*"
    ]
  }

  assignable_scopes = [var.scope]
}

# Custom Role: Security Administrator
resource "azurerm_role_definition" "security_administrator" {
  name        = "Security Administrator"
  scope       = var.scope
  description = "Custom role for security administrators with security and compliance permissions"

  permissions {
    actions = [
      "Microsoft.*/read",
      "Microsoft.Security/*",
      "Microsoft.KeyVault/vaults/*",
      "Microsoft.KeyVault/locations/*",
      "Microsoft.OperationalInsights/workspaces/*",
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.Authorization/policySetDefinitions/*",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Insights/metrics/*",
      "Microsoft.Insights/diagnosticSettings/*"
    ]
    not_actions = []
  }

  assignable_scopes = [var.scope]
}

# Custom Role: Landing Zone Owner
resource "azurerm_role_definition" "landing_zone_owner" {
  name        = "Landing Zone Owner"
  scope       = var.scope
  description = "Custom role for landing zone owners with contributor rights to assigned subscription"

  permissions {
    actions = [
      "Microsoft.*/read",
      "Microsoft.Compute/*",
      "Microsoft.Storage/*",
      "Microsoft.Network/virtualNetworks/*",
      "Microsoft.Network/networkSecurityGroups/*",
      "Microsoft.Network/loadBalancers/*",
      "Microsoft.Network/publicIPAddresses/*",
      "Microsoft.Web/*",
      "Microsoft.Sql/*",
      "Microsoft.KeyVault/vaults/*/read",
      "Microsoft.Resources/*"
    ]
    not_actions = [
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/*"
    ]
  }

  assignable_scopes = [var.scope]
}

