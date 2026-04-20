resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }
}

resource "azurerm_subnet" "app_gateway" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "container_apps" {
  name                 = "snet-containerApps"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/23"]

  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_network_security_group" "app_gateway" {
  name                = "nsg-appgw"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AppGW-Management"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "app_gateway" {
  subnet_id                 = azurerm_subnet.app_gateway.id
  network_security_group_id = azurerm_network_security_group.app_gateway.id
}

resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-appgw-${random_string.suffix.result}"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                = "Standard"

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-${var.project_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  identity {
    type = "SystemAssigned"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.app_gateway.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name  = "container-app-pool"
    fqdns = [azurerm_container_app.nginx.latest_revision_fqdn]
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol             = "Https"
    request_timeout      = 30
    host_name            = azurerm_container_app.nginx.latest_revision_fqdn
    
    probe_name = "health-probe"
  }

  probe {
    name                = "health-probe"
    protocol            = "Https"
    path                = "/"
    host                = azurerm_container_app.nginx.latest_revision_fqdn
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    
    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-ip-config"
    frontend_port_name             = "http-port"
    protocol                      = "Http"
  }

  request_routing_rule {
    name                       = "http-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "container-app-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }

  tags = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }

  depends_on = [
    azurerm_container_app.nginx
  ]
}