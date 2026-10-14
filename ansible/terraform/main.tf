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


data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "existing" {
  name                = "test-vnet-iot"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.15.0.0/16"]
}

resource "azurerm_subnet" "private" {
  name                 = "test-subnet-iot"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.existing.name
  address_prefixes     = ["10.15.1.0/24"]
}

# resource "azurerm_subnet" "aks" {
#   name                 = "aks-subnet-iot"
#   resource_group_name  = data.azurerm_resource_group.existing.name
#   virtual_network_name = azurerm_virtual_network.existing.name
#   address_prefixes     = ["10.15.2.0/24"]
# }
# resource "azurerm_subnet" "lb" {
#   name                 = "lb-subnet-iot"
#   resource_group_name  = data.azurerm_resource_group.existing.name
#   virtual_network_name = azurerm_virtual_network.existing.name
#   address_prefixes     = ["10.15.3.0/24"]
# }

resource "azurerm_network_security_group" "private_vm" {
  name                = "test-private-vm-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.1.1.4/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-Other-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # PostgreSQL access from the AKS subnet
#   security_rule {
#     name                       = "Allow-PostgreSQL-From-AKS"
#     priority                   = 130
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "5432"
#     source_address_prefix      = "10.15.2.0/24"
#     destination_address_prefix = "*"
#   }
}
resource "azurerm_network_interface_security_group_association" "private_vm" {
  network_interface_id      = azurerm_network_interface.private_vm.id
  network_security_group_id = azurerm_network_security_group.private_vm.id
}
resource "azurerm_network_interface" "private_vm" {
  name                = "test-private-vm-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  name                = "test-nat-public-ip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  allocation_method = "Static"
  sku               = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "private" {
  name                = "test-nat-gateway"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  sku_name = "Standard"
}

# Attach public IP to NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "private" {
  nat_gateway_id       = azurerm_nat_gateway.private.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate NAT Gateway with private subnet
resource "azurerm_subnet_nat_gateway_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.private.id
}


