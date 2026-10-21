# Backend configuration for remote state storage
# Note: Backend must be initialized with Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate001"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
    
    # These can be provided via environment variables:
    # ARM_ACCESS_KEY or ARM_SAS_TOKEN
  }
}
