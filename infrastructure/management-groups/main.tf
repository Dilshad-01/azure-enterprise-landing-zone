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
    # resource_group_name  = "RG_TFSTATE_djs01224"
    # storage_account_name = "sttfstatedjs01224"
    # container_name       = "tfstate"
    # key                  = "management-groups.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data source for current subscription
data "azurerm_subscription" "current" {}

# Root Management Group
resource "azurerm_management_group" "root" {
  display_name = "Root Management Group"
  name         = var.root_management_group_id
}

# Platform Management Group
resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  name                       = "platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Landing Zones Management Group
resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing Zones"
  name                       = "landing-zones"
  parent_management_group_id = azurerm_management_group.root.id
}

# Production Management Group
resource "azurerm_management_group" "production" {
  display_name               = "Production"
  name                       = "production"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Non-Production Management Group
resource "azurerm_management_group" "nonproduction" {
  display_name               = "Non-Production"
  name                       = "nonproduction"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Sandbox Management Group
resource "azurerm_management_group" "sandbox" {
  display_name               = "Sandbox"
  name                       = "sandbox"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Subscription Associations (if subscriptions are provided)
resource "azurerm_management_group_subscription_association" "platform" {
  for_each = toset(var.platform_subscriptions)
  
  management_group_id = azurerm_management_group.platform.id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "production" {
  for_each = toset(var.production_subscriptions)
  
  management_group_id = azurerm_management_group.production.id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "nonproduction" {
  for_each = toset(var.nonproduction_subscriptions)
  
  management_group_id = azurerm_management_group.nonproduction.id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "sandbox" {
  for_each = toset(var.sandbox_subscriptions)
  
  management_group_id = azurerm_management_group.sandbox.id
  subscription_id     = "/subscriptions/${each.value}"
}

