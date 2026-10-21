terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate001"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = false
}

# Local variables
locals {
  environment = var.environment
  project     = var.project_name
  location    = var.location

  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name       = "${local.environment}-rg-${local.project}-001"
  location   = local.location

  tags = local.common_tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${local.environment}-vnet-${local.project}-001"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Subnets
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_prefix]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_prefix]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_subnet_prefix]

  delegation {
    name = "Microsoft.Sql/servers"
    service_delegation {
      name    = "Microsoft.Sql/servers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "web" {
  name                = "${local.environment}-nsg-web-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${local.environment}-asp-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${local.environment}-web-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on                 = true
    http2_enabled             = true
    minimum_tls_version       = "1.2"
    remote_debugging_enabled  = false
    use_32_bit_worker_process = false
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.main.instrumentation_key
  }

  tags = local.common_tags
}

# Azure SQL Database
resource "azurerm_mssql_server" "main" {
  name                         = "${local.environment}-sql-${local.project}-001"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = local.common_tags
}

resource "azurerm_mssql_database" "main" {
  name           = "${local.environment}-db-${local.project}-001"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = var.sql_db_sku

  threat_detection_policy {
    state                      = "On"
    disabled_alerts            = []
    email_addresses            = [var.alert_email]
    retention_days             = 30
  }

  tags = local.common_tags
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${local.environment}stg${replace(local.project, "-", "")}001"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = local.common_tags
}

resource "azurerm_storage_container" "app_data" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${local.environment}-appinsights-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = 30

  tags = local.common_tags
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "${local.environment}-lb-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = local.common_tags
}

resource "azurerm_public_ip" "lb" {
  name                = "${local.environment}-pip-lb-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.environment}-law-${local.project}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "ID of the created resource group"
}

output "app_service_default_hostname" {
  value       = azurerm_linux_web_app.main.default_hostname
  description = "Default hostname of the App Service"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  description = "Fully qualified domain name of SQL Server"
}

output "storage_account_id" {
  value       = azurerm_storage_account.main.id
  description = "ID of the storage account"
}
