resource "azurerm_recovery_services_vault" "backup" {
  name                = "devops-recovery-vault"
  location            = azurerm_resource_group.backup.location
  resource_group_name = azurerm_resource_group.backup.name

  sku = "Standard"

  storage_mode_type = "GeoRedundant"

  soft_delete_enabled = true
}