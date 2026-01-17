variable "location" {
  description = "Azure region for non-production spoke resources"
  type        = string
  default     = "East US"
}

variable "spoke_resource_group_name" {
  description = "Name of the resource group for non-production spoke"
  type        = string
  default     = "RG_djs01224_02"
}

variable "spoke_vnet_name" {
  description = "Name of the non-production spoke virtual network"
  type        = string
  default     = "VNET_djs01224_02"
}

variable "spoke_vnet_address_space" {
  description = "Address space for non-production spoke virtual network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "spoke_subnets" {
  description = "Subnet configurations for non-production spoke network"
  type = object({
    app  = string
    data = string
    web  = string
  })
  default = {
    app  = "10.10.1.0/24"
    data = "10.10.2.0/24"
    web  = "10.10.3.0/24"
  }
}

variable "hub_resource_group_name" {
  description = "Name of the hub resource group"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall in the hub"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

