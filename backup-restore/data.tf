data "azurerm_resource_group" "source" {
  name = var.source_resource_group_name
}

data "azurerm_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.source.name
}