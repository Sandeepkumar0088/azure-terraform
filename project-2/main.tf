provider "azurerm" {
  features {}
}

# Existing Resource Group
data "azurerm_resource_group" "rg" {
  name = "devops"
}

# Existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = "devops-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Existing Subnet
data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NIC attached to existing subnet
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
# NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "allow-all-nsg"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "frontend-dev"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_B2ats_v2"

  admin_username = "sandeep"
  admin_password = "Sandeep.,@0088"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "almalinux"
    offer     = "almalinux-x86_64"
    sku       = "9-gen2"
    version   = "latest"
  }
}