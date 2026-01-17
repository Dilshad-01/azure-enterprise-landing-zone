# Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  address_space       = var.hub_vnet_address_space
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnets.firewall]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub_network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnets.bastion]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnets.gateway]
}

resource "azurerm_subnet" "shared_services" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.hub_network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnets.shared_services]
}

resource "azurerm_subnet" "dmz" {
  name                 = "DMZSubnet"
  resource_group_name  = azurerm_resource_group.hub_network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnets.dmz]
}

# Network Security Group for Shared Services
resource "azurerm_network_security_group" "shared_services" {
  name                = "NSG_djs01224"
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "shared_services" {
  subnet_id                 = azurerm_subnet.shared_services.id
  network_security_group_id = azurerm_network_security_group.shared_services.id
}

# Azure Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "PIP_FW_djs01224"
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_azure_firewall" "hub" {
  name                = var.firewall_name
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  threat_intel_mode = var.firewall_threat_intel_mode

  tags = var.tags
}

# Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "PIP_BASTION_djs01224"
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "hub" {
  name                = var.bastion_name
  location            = azurerm_resource_group.hub_network.location
  resource_group_name = azurerm_resource_group.hub_network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# Diagnostic Settings for Hub Network Resources
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "DIAG_FW_djs01224"
  target_resource_id         = azurerm_azure_firewall.hub.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

