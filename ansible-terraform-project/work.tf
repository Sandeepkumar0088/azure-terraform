resource "azurerm_public_ip" "virtual_work" {
  name                = "my-pip-virtual-work"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "virtual_work" {

  name                = "alma-nic-virtual-work"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.virtual_work.id
  }
}

resource "azurerm_linux_virtual_machine" "work" {

  name                = "virtual-work"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2"

  admin_username = "sandeep"
  admin_password = "Sandeep.,@0088"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.virtual_work.id
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