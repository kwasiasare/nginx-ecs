output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.nginx.latest_revision_fqdn
}

output "application_gateway_public_ip" {
  description = "Public IP of Application Gateway"
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "container_registry_login_server" {
  description = "Login server URL for Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}