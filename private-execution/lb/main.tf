terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ============================================================
# VARIABLES
# ============================================================

variable "location" {
  default = "Central India"
}

# Existing frontend VM resource group
variable "frontend_resource_group" {
  default = "rg-roboshop-private"
}

# Existing frontend NIC
variable "frontend_nic_name" {
  default = "roboshop-frontend-nic"
}

# ============================================================
# 1. RESOURCE GROUP
# ============================================================

resource "azurerm_resource_group" "lb" {
  name     = "roboshop-lb-rg"
  location = var.location
}

# ============================================================
# 2. PUBLIC IP
# ============================================================

resource "azurerm_public_ip" "lb" {
  name                = "roboshop-lb-public-ip"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    project = "roboshop"
    purpose = "frontend-load-balancer"
  }
}

# ============================================================
# 3. EXISTING FRONTEND NIC
# ============================================================

data "azurerm_network_interface" "frontend" {
  name                = var.frontend_nic_name
  resource_group_name = var.frontend_resource_group
}

# ============================================================
# 4. PUBLIC LOAD BALANCER
# ============================================================

resource "azurerm_lb" "frontend" {
  name                = "roboshop-frontend-lb"
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-public-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = {
    project = "roboshop"
  }
}

# ============================================================
# 5. BACKEND ADDRESS POOL
# ============================================================

resource "azurerm_lb_backend_address_pool" "frontend" {
  name            = "frontend-backend-pool"
  loadbalancer_id = azurerm_lb.frontend.id
}

# ============================================================
# 6. ADD FRONTEND VM NIC TO BACKEND POOL
# ============================================================

resource "azurerm_network_interface_backend_address_pool_association" "frontend" {
  network_interface_id    = data.azurerm_network_interface.frontend.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
}

# ============================================================
# 7. HEALTH PROBE
# ============================================================

resource "azurerm_lb_probe" "frontend" {
  name            = "frontend-http-probe"
  loadbalancer_id = azurerm_lb.frontend.id

  protocol = "Tcp"
  port     = 80

  interval_in_seconds = 5
  number_of_probes    = 2
}

# ============================================================
# 8. LOAD BALANCING RULE
# ============================================================

resource "azurerm_lb_rule" "frontend_http" {
  name            = "frontend-http"
  loadbalancer_id = azurerm_lb.frontend.id

  protocol      = "Tcp"
  frontend_port = 80
  backend_port  = 80

  frontend_ip_configuration_name = "frontend-public-ip"

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.frontend.id
  ]

  probe_id = azurerm_lb_probe.frontend.id

  idle_timeout_in_minutes = 15

  # enable_tcp_reset = true

  floating_ip_enabled = false

  disable_outbound_snat = true
}

# ============================================================
# 9. OUTPUTS
# ============================================================

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "frontend_url" {
  value = "http://${azurerm_public_ip.lb.ip_address}"
}

output "load_balancer_name" {
  value = azurerm_lb.frontend.name
}

output "backend_pool_name" {
  value = azurerm_lb_backend_address_pool.frontend.name
}