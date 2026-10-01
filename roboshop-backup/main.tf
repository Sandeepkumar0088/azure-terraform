terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# --------------------------------------------------
# Resource Group for Backup
# --------------------------------------------------

resource "azurerm_resource_group" "backup" {
  name     = "roboshop-project-backup-rg"
  location = "Central India"
}


# --------------------------------------------------
# Recovery Services Vault
# --------------------------------------------------

resource "azurerm_recovery_services_vault" "backup" {
  name                = "roboshop-project-backup-vault"
  location            = azurerm_resource_group.backup.location
  resource_group_name = azurerm_resource_group.backup.name

  sku               = "Standard"
  storage_mode_type = "GeoRedundant"
}


# --------------------------------------------------
# Backup Policy
# --------------------------------------------------

resource "azurerm_backup_policy_vm" "daily" {
  name                = "roboshop-project-backup-policy"
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.backup.name

  timezone = "India Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}


# --------------------------------------------------
# Existing VM names
# --------------------------------------------------

variable "vm_names" {
  type = set(string)

  default = [
    "frontend",
    "mongodb",
    "catalogue",
    "user",
    "redis",
    "cart",
    "mysql",
    "shipping",
    "rabbitmq",
    "payment"
  ]
}


# --------------------------------------------------
# Get existing VMs
# --------------------------------------------------

data "azurerm_virtual_machine" "vm" {

  for_each = var.vm_names

  name                = each.value
  resource_group_name = "roboshop-rg"
}


# --------------------------------------------------
# Protect all VMs
# --------------------------------------------------

resource "azurerm_backup_protected_vm" "vm" {

  for_each = data.azurerm_virtual_machine.vm

  resource_group_name = azurerm_resource_group.backup.name

  recovery_vault_name = azurerm_recovery_services_vault.backup.name

  source_vm_id = each.value.id

  backup_policy_id = azurerm_backup_policy_vm.daily.id
}