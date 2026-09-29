data "azurerm_snapshot" "jenkins" {
  name                = var.snapshot_name
  resource_group_name = var.resource_group_name
}
data "azurerm_virtual_network" "existing" {
  name                = "work-vnet"
  resource_group_name = "work"
}

data "azurerm_subnet" "existing" {
  name                 = "default"
  virtual_network_name  = data.azurerm_virtual_network.existing.name
  resource_group_name   = data.azurerm_virtual_network.existing.resource_group_name
}