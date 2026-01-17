output "root_management_group_id" {
  description = "The ID of the root management group"
  value       = azurerm_management_group.root.id
}

output "platform_management_group_id" {
  description = "The ID of the Platform management group"
  value       = azurerm_management_group.platform.id
}

output "landing_zones_management_group_id" {
  description = "The ID of the Landing Zones management group"
  value       = azurerm_management_group.landing_zones.id
}

output "production_management_group_id" {
  description = "The ID of the Production management group"
  value       = azurerm_management_group.production.id
}

output "nonproduction_management_group_id" {
  description = "The ID of the Non-Production management group"
  value       = azurerm_management_group.nonproduction.id
}

output "sandbox_management_group_id" {
  description = "The ID of the Sandbox management group"
  value       = azurerm_management_group.sandbox.id
}

