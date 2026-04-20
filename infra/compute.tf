resource "azurerm_container_app_environment" "main" {
  name                     = "cae-${var.project_name}-${random_string.suffix.result}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  infrastructure_subnet_id = azurerm_subnet.container_apps.id
  internal_load_balancer_enabled = true

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }
}

resource "azurerm_container_app" "nginx" {
  name                         = "ca-nginx-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode               = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    min_replicas = 0
    max_replicas = 10

    container {
      name   = "nginx"
      image  = "${azurerm_container_registry.main.login_server}/${var.container_image}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "APPINSIGHTS_CONNECTIONSTRING"
        secret_name = "appinsights-connection-string"
      }
    }
  }

  secret {
    name  = "appinsights-connection-string"
    value = azurerm_application_insights.main.connection_string
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = false
    target_port              = 80
    transport               = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_container_app.nginx.identity[0].principal_id
  }

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}

resource "azurerm_container_registry" "main" {
  name                = "acr${replace(var.project_name, "-", "")}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "Basic"
  admin_enabled      = false

  identity {
    type = "SystemAssigned"
  }

  encryption {
    enabled = true
  }

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}