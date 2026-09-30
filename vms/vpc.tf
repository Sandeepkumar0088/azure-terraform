resource "azurerm_resource_group" "vms" {
  name = "vms"
  location = "Central India"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "vms"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "vms"
  resource_group_name  = azurerm_resource_group.vms.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}