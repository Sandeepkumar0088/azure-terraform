terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "azure"
    storage_account_name = "asdfghjlkxbcwbcolnw2o"
    container_name       = "sandeep"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "bb2e4b65-7863-4a64-99b2-cd7d29b73bd7"
}