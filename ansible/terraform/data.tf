# Existing resource group
data "azurerm_resource_group" "existing" {
  name = "test-iot"
  location = "Central India"
}

# Existing VNet: test-iot-vm-vnet (10.1.0.0/16)
data "azurerm_virtual_network" "existing" {
  name                = "test-iot-vm-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}