terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-almalinux"
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
  for_each = var.vms
  name                = "my-pip-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# resource "azurerm_network_security_group" "nsg" {
#   name                = "my-nsg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#
#   security_rule {
#     name                       = "Allow-SSH"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#
#   security_rule {
#     name                       = "Allow-HTTP"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#
#   security_rule {
#     name                       = "Allow-8080"
#     priority                   = 120
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "8080"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

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
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {

  for_each = var.vms
  name                = "alma-nic-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each = var.vms

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

variable "vms" {
  default = {
    frontend    = "10.0.1.8"
    mongodb     = "10.0.1.9"
    catalogue   = "10.0.1.13"
    user        = "10.0.1.7"
    redis       = "10.0.1.4"
    cart        = "10.0.1.11"
    mysql       = "10.0.1.12"
    shipping    = "10.0.1.5"
    rabbitmq    = "10.0.1.10"
    payment     = "10.0.1.6"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {

  for_each = var.vms

  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2"

  admin_username = "sandeep"
  admin_password = "Sandeep.,@0088"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
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
data "azurerm_dns_zone" "main" {
  name = "sandeepkumarpenta.online"
  resource_group_name = "work"
}

resource "azurerm_dns_a_record" "records" {

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]

  for_each = var.vms

  name = "${each.key}-dev"
  zone_name = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl = 5
  records = [ azurerm_linux_virtual_machine.vm[each.key].private_ip_address ]
}

resource "null_resource" "ansible" {
  depends_on = [
    azurerm_linux_virtual_machine.vm,
    azurerm_dns_a_record.records
  ]

  for_each   = var.vms

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "sandeep"
      password = "Sandeep.,@0088"
      host     = azurerm_linux_virtual_machine.vm[each.key].public_ip_address
      timeout  = "5m"
    }

    inline = [
      "echo 'sandeep' > ~/vault-pass.txt",
      "chmod 600 ~/vault-pass.txt",
      "sudo dnf install -y ansible-core npm unzip git",
      "ansible-pull -i localhost, -U https://github.com/Sandeepkumar0088/azure-ansible.git main.yml -e component=${each.key} -e env=dev --vault-password-file ~/vault-pass.txt"
    ]
  }
}
