terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    recovery_service {
      vm_backup_stop_protection_and_retain_data_on_destroy = true
      purge_protected_items_from_vault_on_destroy          = true
    }
  }
}

data "azurerm_virtual_machine" "nginx" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_recovery_services_vault" "nginx" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "nginx" {
  name                = var.backup_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.nginx.name

  timezone = "India Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "nginx" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.nginx.name

  source_vm_id = data.azurerm_virtual_machine.nginx.id

  backup_policy_id = azurerm_backup_policy_vm.nginx.id
}