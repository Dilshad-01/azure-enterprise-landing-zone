variable "location" {
  description = "Azure region for hub resources"
  type        = string
  default     = "East US"
}

variable "hub_resource_group_name" {
  description = "Name of the resource group for hub resources"
  type        = string
  default     = "RG_djs01224"
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
  default     = "VNET_djs01224"
}

variable "hub_vnet_address_space" {
  description = "Address space for hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnets" {
  description = "Subnet configurations for hub network"
  type = object({
    firewall       = string
    bastion        = string
    gateway        = string
    shared_services = string
    dmz            = string
  })
  default = {
    firewall        = "10.0.0.0/26"
    bastion         = "10.0.0.64/26"
    gateway         = "10.0.0.128/27"
    shared_services = "10.0.1.0/24"
    dmz             = "10.0.2.0/24"
  }
}

variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
  default     = "FW_djs01224"
}

variable "firewall_sku_name" {
  description = "SKU name for Azure Firewall"
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  description = "SKU tier for Azure Firewall"
  type        = string
  default     = "Standard"
}

variable "firewall_threat_intel_mode" {
  description = "Threat intelligence mode for Azure Firewall"
  type        = string
  default     = "Alert"
}

variable "bastion_name" {
  description = "Name of the Azure Bastion host"
  type        = string
  default     = "BASTION_djs01224"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "LAW_djs01224"
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 90
}

variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
  default     = "KV_djs01224"
}

variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

