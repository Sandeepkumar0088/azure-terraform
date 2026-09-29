resource "azurerm_resource_group" "backup" {
  name     = var.backup_resource_group_name
  location = var.location
}