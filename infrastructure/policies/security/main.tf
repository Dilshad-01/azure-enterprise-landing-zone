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

# Policy Definition: Require NSG on Subnets
resource "azurerm_policy_definition" "require_nsg_on_subnets" {
  name         = "require-nsg-on-subnets"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Network Security Group on Subnets"
  description  = "This policy ensures that all subnets have a Network Security Group associated"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Network/virtualNetworks/subnets"
        },
        {
          field = "Microsoft.Network/virtualNetworks/subnets/networkSecurityGroup.id"
          exists = false
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require Encryption at Rest
resource "azurerm_policy_definition" "require_encryption_at_rest" {
  name         = "require-encryption-at-rest"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Encryption at Rest for Storage Accounts"
  description  = "This policy ensures that all storage accounts have encryption enabled"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field = "Microsoft.Storage/storageAccounts/encryption.services.blob.enabled"
          equals = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require TLS 1.2
resource "azurerm_policy_definition" "require_tls_12" {
  name         = "require-tls-12"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require TLS 1.2 for Storage Accounts"
  description  = "This policy ensures that storage accounts only accept TLS 1.2 or higher"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          anyOf = [
            {
              field = "Microsoft.Storage/storageAccounts/minimumTlsVersion"
              notEquals = "TLS1_2"
            },
            {
              field = "Microsoft.Storage/storageAccounts/minimumTlsVersion"
              exists = false
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Block Public IPs on VMs
resource "azurerm_policy_definition" "block_public_ips_on_vms" {
  name         = "block-public-ips-on-vms"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Block Public IPs on Virtual Machines"
  description  = "This policy prevents deployment of VMs with public IP addresses"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          count = {
            field = "Microsoft.Compute/virtualMachines/networkProfile.networkInterfaces[*].id"
            where = {
              anyOf = [
                {
                  field = "Microsoft.Network/networkInterfaces/ipConfigurations[*].publicIpAddress.id"
                  exists = true
                }
              ]
            }
          }
          greater = 0
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require Managed Identity
resource "azurerm_policy_definition" "require_managed_identity" {
  name         = "require-managed-identity"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Managed Identity for Virtual Machines"
  description  = "This policy ensures that VMs use managed identities for authentication"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          field = "Microsoft.Compute/virtualMachines/identity.type"
          notEquals = "SystemAssigned"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

# Policy Definition: Require Diagnostic Settings
resource "azurerm_policy_definition" "require_diagnostic_settings" {
  name         = "require-diagnostic-settings"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Diagnostic Settings for Resources"
  description  = "This policy ensures that diagnostic settings are configured for all resources"

  policy_rule = jsonencode({
    if = {
      field = "type"
      in = [
        "Microsoft.Compute/virtualMachines",
        "Microsoft.Storage/storageAccounts",
        "Microsoft.Network/loadBalancers",
        "Microsoft.Network/applicationGateways"
      ]
    }
    then = {
      effect = "auditIfNotExists"
      details = {
        type = "Microsoft.Insights/diagnosticSettings"
        existenceCondition = {
          allOf = [
            {
              field = "Microsoft.Insights/diagnosticSettings/logs.enabled"
              equals = "true"
            }
          ]
        }
      }
    }
  })
}

