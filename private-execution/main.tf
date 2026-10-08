terraform {
  required_version = ">= 1.6.0"

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

# ============================================================
# RESOURCE GROUP
# ============================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ============================================================
# VIRTUAL NETWORK
# ============================================================

resource "azurerm_virtual_network" "main" {
  name                = "roboshop-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = [
    "10.20.0.0/16"
  ]
}

# ============================================================
# BASTION SUBNET
# ============================================================

resource "azurerm_subnet" "bastion" {
  name                 = "bastion-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    "10.20.1.0/24"
  ]
}

# ============================================================
# PRIVATE VM SUBNET
# ============================================================

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    "10.20.2.0/24"
  ]
}

# ============================================================
# BASTION PUBLIC IP
# ============================================================

resource "azurerm_public_ip" "bastion" {
  name                = "roboshop-bastion-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"
}

# ============================================================
# NAT PUBLIC IP
# ============================================================

resource "azurerm_public_ip" "nat" {
  name                = "roboshop-nat-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"
}

# ============================================================
# NAT GATEWAY
# ============================================================

resource "azurerm_nat_gateway" "main" {
  name                = "roboshop-nat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# ============================================================
# NAT PUBLIC IP ASSOCIATION
# ============================================================

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# ============================================================
# NAT -> PRIVATE SUBNET
# ============================================================

resource "azurerm_subnet_nat_gateway_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# ============================================================
# NAT -> BASTION SUBNET
# ============================================================

resource "azurerm_subnet_nat_gateway_association" "bastion" {
  subnet_id      = azurerm_subnet.bastion.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# ============================================================
# BASTION NSG
# ============================================================

resource "azurerm_network_security_group" "bastion" {
  name                = "roboshop-bastion-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # ----------------------------------------------------------
  # SSH FROM MANAGEMENT SERVER TO BASTION
  # ----------------------------------------------------------

security_rule {
  name                       = "Allow-SSH-Management-To-Bastion"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "20.192.13.93/32"
  destination_address_prefix = "*"
}

  # ----------------------------------------------------------
  # ALLOW VNET TRAFFIC
  # ----------------------------------------------------------

  security_rule {
    name                       = "Allow-VNet-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"

    source_port_range      = "*"
    destination_port_range = "*"

    source_address_prefix      = "10.20.0.0/16"
    destination_address_prefix = "*"
  }
}

# ============================================================
# BASTION NSG ASSOCIATION
# ============================================================

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# ============================================================
# PRIVATE VM NSG
# ============================================================

resource "azurerm_network_security_group" "private" {
  name                = "roboshop-private-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # ----------------------------------------------------------
  # SSH ONLY FROM BASTION SUBNET
  # ----------------------------------------------------------

  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range      = "*"
    destination_port_range = "22"

    source_address_prefix      = "10.20.1.0/24"
    destination_address_prefix = "*"
  }

  # ----------------------------------------------------------
  # ALL TCP FROM VNET
  #
  # OPTIONAL LAB RULE
  #
  # This allows private VMs to communicate with each other
  # over TCP ports.
  # ----------------------------------------------------------

  security_rule {
    name                       = "Allow-All-TCP-From-VNet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range      = "*"
    destination_port_range = "*"

    source_address_prefix      = "10.20.0.0/16"
    destination_address_prefix = "*"
  }

  # ----------------------------------------------------------
  # HTTP
  # ----------------------------------------------------------

  security_rule {
    name                       = "Allow-HTTP-From-VNet"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range      = "*"
    destination_port_range = "80"

    source_address_prefix      = "10.20.0.0/16"
    destination_address_prefix = "*"
  }

  # ----------------------------------------------------------
  # HTTPS
  # ----------------------------------------------------------

  security_rule {
    name                       = "Allow-HTTPS-From-VNet"
    priority                   = 220
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = "10.20.0.0/16"
    destination_address_prefix = "*"
  }
}

# ============================================================
# PRIVATE SUBNET NSG ASSOCIATION
# ============================================================

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# ============================================================
# BASTION NIC
# ============================================================

resource "azurerm_network_interface" "bastion" {
  name                = "roboshop-bastion-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "internal"

    subnet_id = azurerm_subnet.bastion.id

    private_ip_address_allocation = "Static"

    private_ip_address = "10.20.1.4"

    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# ============================================================
# PRIVATE VM NICS
# ============================================================

resource "azurerm_network_interface" "private" {

  for_each = var.private_vm_ips

  name                = "roboshop-${each.key}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "internal"

    subnet_id = azurerm_subnet.private.id

    private_ip_address_allocation = "Dynamic"

    # private_ip_address = azurerm_linux_virtual_machine.private[each.key].private_ip_address

    # IMPORTANT:
    #
    # No public_ip_address_id
    #
    # Therefore these VMs have private IPs only.
  }
}

# ============================================================
# BASTION VM
# ============================================================

resource "azurerm_linux_virtual_machine" "bastion" {

  name = "roboshop-bastion-vm"

  computer_name = "bastion"

  resource_group_name = azurerm_resource_group.main.name

  location = azurerm_resource_group.main.location

  size = "Standard_B2ats_v2"

  admin_username = var.admin_username

  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.bastion.id
  ]

  os_disk {
    name                 = "roboshop-bastion-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

#   source_image_reference {

#     publisher = var.almalinux_publisher

#     offer = var.almalinux_offer

#     sku = var.almalinux_sku

#     version = var.almalinux_version
#   }

    source_image_reference {
    publisher = "almalinux"
    offer     = "almalinux-x86_64"
    sku       = "9-gen2"
    version   = "latest"
  }
}

# ============================================================
# PRIVATE VMs
# ============================================================

resource "azurerm_linux_virtual_machine" "private" {

  for_each = var.private_vm_ips

  name = "roboshop-${each.key}"

  computer_name = each.key

  resource_group_name = azurerm_resource_group.main.name

  location = azurerm_resource_group.main.location

  size = each.value

  admin_username = var.admin_username

  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.private[each.key].id
  ]

  os_disk {
    name                 = "roboshop-${each.key}-osdisk"
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