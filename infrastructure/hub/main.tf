terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
  
  backend "azurerm" {
    # Configure backend in terraform.tfvars or via environment variables
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Data sources
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# Resource Group for Hub Network
resource "azurerm_resource_group" "hub_network" {
  name     = var.hub_resource_group_name
  location = var.location

  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "hub" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "hub" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Key Vault Access Policy for Current User
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.hub.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore", "Import"
  ]
}

