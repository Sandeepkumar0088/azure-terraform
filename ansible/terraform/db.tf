# Private subnet for PostgreSQL
resource "azurerm_subnet" "postgres" {
  name                 = "postgres-private-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = ["10.1.2.0/24"]
}

# NSG for PostgreSQL VM
resource "azurerm_network_security_group" "postgres" {
  name                = "postgres-private-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  # Allow SSH only from the work VM
  security_rule {
    name                       = "Allow-SSH-From-Work-VM"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.1.1.4/32"
    destination_address_prefix = "*"
  }

  # Deny SSH from all other sources
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
}

# NIC for PostgreSQL VM; no public IP
resource "azurerm_network_interface" "postgres" {
  name                = "postgres-private-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.postgres.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.2.4"
  }
}

# Attach NSG to PostgreSQL NIC
resource "azurerm_network_interface_security_group_association" "postgres" {
  network_interface_id      = azurerm_network_interface.postgres.id
  network_security_group_id = azurerm_network_security_group.postgres.id
}

# NAT Gateway public IP for outbound connectivity
resource "azurerm_public_ip" "nat" {
  name                = "postgres-nat-public-ip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  allocation_method = "Static"
  sku               = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "postgres" {
  name                = "postgres-nat-gateway"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "postgres" {
  nat_gateway_id       = azurerm_nat_gateway.postgres.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate NAT Gateway with private subnet
resource "azurerm_subnet_nat_gateway_association" "postgres" {
  subnet_id      = azurerm_subnet.postgres.id
  nat_gateway_id = azurerm_nat_gateway.postgres.id
}

# Private PostgreSQL VM
resource "azurerm_linux_virtual_machine" "postgres" {
  name                = "postgres-private-vm"
  computer_name       = "postgres-private"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2ats_v2"

  admin_username                  = "ubuntu"
  admin_password                  = "Sandeep.,@0088"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.postgres.id
  ]

  os_disk {
    name                 = "postgres-private-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  disk_controller_type = "SCSI"
}