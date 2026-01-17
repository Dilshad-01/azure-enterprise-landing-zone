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
  }
}

# Data sources
data "azurerm_subscription" "current" {}
data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

# Resource Group for Non-Production Spoke
resource "azurerm_resource_group" "spoke_nonprod" {
  name     = var.spoke_resource_group_name
  location = var.location

  tags = merge(var.tags, {
    Environment = "Non-Production"
  })
}

# Non-Production Spoke Virtual Network
resource "azurerm_virtual_network" "spoke_nonprod" {
  name                = var.spoke_vnet_name
  address_space       = var.spoke_vnet_address_space
  location            = azurerm_resource_group.spoke_nonprod.location
  resource_group_name = azurerm_resource_group.spoke_nonprod.name

  tags = merge(var.tags, {
    Environment = "Non-Production"
  })
}

# Subnets
resource "azurerm_subnet" "app" {
  name                 = "AppSubnet"
  resource_group_name  = azurerm_resource_group.spoke_nonprod.name
  virtual_network_name = azurerm_virtual_network.spoke_nonprod.name
  address_prefixes     = [var.spoke_subnets.app]
}

resource "azurerm_subnet" "data" {
  name                 = "DataSubnet"
  resource_group_name  = azurerm_resource_group.spoke_nonprod.name
  virtual_network_name = azurerm_virtual_network.spoke_nonprod.name
  address_prefixes     = [var.spoke_subnets.data]
}

resource "azurerm_subnet" "web" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.spoke_nonprod.name
  virtual_network_name = azurerm_virtual_network.spoke_nonprod.name
  address_prefixes     = [var.spoke_subnets.web]
}

# Route Table for Hub Routing
resource "azurerm_route_table" "spoke_nonprod" {
  name                          = "RT_djs01224_02"
  location                      = azurerm_resource_group.spoke_nonprod.location
  resource_group_name           = azurerm_resource_group.spoke_nonprod.name
  disable_bgp_route_propagation = false

  route {
    name           = "DefaultRouteToHub"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  tags = merge(var.tags, {
    Environment = "Non-Production"
  })
}

# Associate Route Table with Subnets
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = azurerm_route_table.spoke_nonprod.id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = azurerm_subnet.data.id
  route_table_id = azurerm_route_table.spoke_nonprod.id
}

resource "azurerm_subnet_route_table_association" "web" {
  subnet_id      = azurerm_subnet.web.id
  route_table_id = azurerm_route_table.spoke_nonprod.id
}

# Network Security Groups
resource "azurerm_network_security_group" "web" {
  name                = "NSG_djs01224_02"
  location            = azurerm_resource_group.spoke_nonprod.location
  resource_group_name = azurerm_resource_group.spoke_nonprod.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Environment = "Non-Production"
  })
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# VNet Peering: Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "PEERING_djs01224_03"
  resource_group_name       = azurerm_resource_group.spoke_nonprod.name
  virtual_network_name      = azurerm_virtual_network.spoke_nonprod.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

# VNet Peering: Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "PEERING_djs01224_04"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_nonprod.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit         = true
  use_remote_gateways           = false
}

