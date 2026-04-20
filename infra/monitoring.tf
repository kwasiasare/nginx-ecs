data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project_name}-${random_string.suffix.result}"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                = "PerGB2018"
  retention_in_days  = 30

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.project_name}-${random_string.suffix.result}"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id       = azurerm_log_analytics_workspace.main.id
  application_type   = "web"

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}