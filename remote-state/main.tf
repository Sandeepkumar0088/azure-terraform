resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "Central India"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "my-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow ALL inbound traffic
  security_rule {
    name                       = "Allow-All-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"

    source_port_range          = "*"
    destination_port_range     = "*"

    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # Allow ALL outbound traffic
  security_rule {
    name                       = "Allow-All-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "attach_nsg_to_subnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {

  name                = "alma-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {

  name                = "vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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

resource "null_resource" "ansible" {
  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "sandeep"
      password = "Sandeep.,@0088"
      host     = azurerm_linux_virtual_machine.vm.public_ip_address
      timeout  = "2m"
    }

    inline = [
      "sudo dnf module disable nginx -y",
      "sudo dnf module enable nginx:1.24 -y",
      "sudo dnf install nginx unzip -y",
      "sudo rm -rf /usr/share/nginx/html/*",
      "curl -L -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip",
      "sudo unzip -o /tmp/frontend.zip -d /usr/share/nginx/html",
      "sudo systemctl enable nginx",
      "sudo systemctl restart nginx"      
    ]
  }
}