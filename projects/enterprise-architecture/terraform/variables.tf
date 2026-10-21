variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "app"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_prefix" {
  description = "Address prefix for web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_prefix" {
  description = "Address prefix for app subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_subnet_prefix" {
  description = "Address prefix for data subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "app_service_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "S1"

  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "S2", "S3", "P1V2", "P2V2", "P3V2"], var.app_service_sku)
    error_message = "app_service_sku must be a valid App Service SKU."
  }
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sql_admin_password) >= 12 && can(regex("[A-Z]", var.sql_admin_password)) && can(regex("[0-9]", var.sql_admin_password)) && can(regex("[!@#$%^&*]", var.sql_admin_password))
    error_message = "SQL password must be at least 12 characters with uppercase, number, and special character."
  }
}

variable "sql_db_sku" {
  description = "SKU for SQL Database"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sql_db_sku)
    error_message = "sql_db_sku must be Basic, Standard, or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "storage_replication_type must be a valid Azure storage replication type."
  }
}

variable "alert_email" {
  description = "Email for security alerts"
  type        = string
  default     = "security@company.com"
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default = {
    CostCenter = "Engineering"
    Owner      = "Platform Team"
  }
}
