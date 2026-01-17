# Role Assignment: Platform Administrator
resource "azurerm_role_assignment" "platform_admin" {
  count                = var.platform_admin_group_object_id != "" ? 1 : 0
  scope                = var.scope
  role_definition_id   = azurerm_role_definition.platform_administrator.role_definition_resource_id
  principal_id         = var.platform_admin_group_object_id
  skip_service_principal_aad_check = true
}

# Role Assignment: Network Administrator
resource "azurerm_role_assignment" "network_admin" {
  count                = var.network_admin_group_object_id != "" ? 1 : 0
  scope                = var.scope
  role_definition_id   = azurerm_role_definition.network_administrator.role_definition_resource_id
  principal_id         = var.network_admin_group_object_id
  skip_service_principal_aad_check = true
}

# Role Assignment: Security Administrator
resource "azurerm_role_assignment" "security_admin" {
  count                = var.security_admin_group_object_id != "" ? 1 : 0
  scope                = var.scope
  role_definition_id   = azurerm_role_definition.security_administrator.role_definition_resource_id
  principal_id         = var.security_admin_group_object_id
  skip_service_principal_aad_check = true
}

