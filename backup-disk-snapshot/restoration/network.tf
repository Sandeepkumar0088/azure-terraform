resource "azurerm_virtual_network" "restore" {
  name                = "restore-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["20.1.0.0/16"]
}

resource "azurerm_subnet" "restore" {
  name                 = "restore-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.restore.name

  address_prefixes = ["20.1.1.0/24"]
}

resource "azurerm_public_ip" "restore" {
  name                = "nginx-restored-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
}

resource "azurerm_network_interface" "restore" {
  name                = "nginx-restored-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.restore.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.restore.id
  }
}