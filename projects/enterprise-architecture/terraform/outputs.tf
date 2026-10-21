# Output values for deployed infrastructure

output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = azurerm_virtual_network.main.name
}

output "web_subnet_id" {
  description = "Web Subnet ID"
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "App Subnet ID"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "Data Subnet ID"
  value       = azurerm_subnet.data.id
}

output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "App Service Name"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "App Service Default Hostname"
  value       = azurerm_linux_web_app.main.default_hostname
  sensitive   = false
}

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.main.id
}

output "sql_server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_fqdn" {
  description = "SQL Server Fully Qualified Domain Name"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  sensitive   = false
}

output "sql_database_id" {
  description = "SQL Database ID"
  value       = azurerm_mssql_database.main.id
}

output "sql_database_name" {
  description = "SQL Database Name"
  value       = azurerm_mssql_database.main.name
}

output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Storage Account Name"
  value       = azurerm_storage_account.main.name
}

output "storage_primary_blob_endpoint" {
  description = "Primary Blob Endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
  sensitive   = false
}

output "load_balancer_id" {
  description = "Load Balancer ID"
  value       = azurerm_lb.main.id
}

output "load_balancer_public_ip" {
  description = "Load Balancer Public IP"
  value       = azurerm_public_ip.lb.ip_address
  sensitive   = false
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace Name"
  value       = azurerm_log_analytics_workspace.main.name
}

output "nsg_web_id" {
  description = "Web Network Security Group ID"
  value       = azurerm_network_security_group.web.id
}

output "environment" {
  description = "Deployment Environment"
  value       = local.environment
}

output "location" {
  description = "Azure Region"
  value       = local.location
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment              = local.environment
    resource_group           = azurerm_resource_group.main.name
    vnet_name                = azurerm_virtual_network.main.name
    app_service_name         = azurerm_linux_web_app.main.name
    sql_server_name          = azurerm_mssql_server.main.name
    storage_account_name     = azurerm_storage_account.main.name
    app_insights_name        = azurerm_application_insights.main.name
    log_analytics_workspace  = azurerm_log_analytics_workspace.main.name
  }
}
