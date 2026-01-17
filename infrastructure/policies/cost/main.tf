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

# Policy Definition: Restrict VM SKUs
resource "azurerm_policy_definition" "restrict_vm_skus" {
  name         = "restrict-vm-skus"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Restrict Allowed VM SKUs"
  description  = "This policy restricts the VM SKUs that can be deployed based on environment"

  parameters = jsonencode({
    allowedSkus = {
      type = "Array"
      metadata = {
        displayName = "Allowed VM SKUs"
        description = "List of allowed VM SKU names"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          field = "Microsoft.Compute/virtualMachines/sku.name"
          notIn = "[parameters('allowedSkus')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Restrict Storage Account SKUs
resource "azurerm_policy_definition" "restrict_storage_skus" {
  name         = "restrict-storage-skus"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Restrict Storage Account SKUs"
  description  = "This policy restricts the storage account SKUs that can be deployed"

  parameters = jsonencode({
    allowedSkus = {
      type = "Array"
      metadata = {
        displayName = "Allowed Storage SKUs"
        description = "List of allowed storage account SKU names"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field = "Microsoft.Storage/storageAccounts/sku.name"
          notIn = "[parameters('allowedSkus')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require Auto-Shutdown for Non-Production VMs
resource "azurerm_policy_definition" "require_auto_shutdown" {
  name         = "require-auto-shutdown"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Auto-Shutdown Schedule for Non-Production VMs"
  description  = "This policy ensures that non-production VMs have auto-shutdown configured"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          field = "tags.Environment"
          in = ["NonProd", "Dev", "Test", "Sandbox"]
        },
        {
          count = {
            field = "Microsoft.Compute/virtualMachines/extensions[*]"
            where = {
              field = "Microsoft.Compute/virtualMachines/extensions/type"
              equals = "Microsoft.DevTestLab/schedules"
            }
          }
          equals = 0
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

# Policy Definition: Block Expensive Database SKUs
resource "azurerm_policy_definition" "block_expensive_db_skus" {
  name         = "block-expensive-db-skus"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Block Expensive Database SKUs in Non-Production"
  description  = "This policy prevents deployment of expensive database SKUs in non-production environments"

  parameters = jsonencode({
    blockedSkus = {
      type = "Array"
      metadata = {
        displayName = "Blocked Database SKUs"
        description = "List of database SKU names that should be blocked"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          in = [
            "Microsoft.Sql/servers",
            "Microsoft.DBforPostgreSQL/servers",
            "Microsoft.DBforMySQL/servers"
          ]
        },
        {
          field = "tags.Environment"
          in = ["NonProd", "Dev", "Test", "Sandbox"]
        },
        {
          field = "sku.name"
          in = "[parameters('blockedSkus')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

