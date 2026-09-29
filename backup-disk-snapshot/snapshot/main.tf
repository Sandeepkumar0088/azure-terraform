terraform {
  required_version = ">= 1.6.0"

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

data "azurerm_managed_disk" "jenkins_os" {
  name                = "jenkins-osdisk"
  resource_group_name = "rg-almalinux"
}

resource "azurerm_snapshot" "jenkins" {
  name                = "jenkins-os-snapshot"
  location            = data.azurerm_managed_disk.jenkins_os.location
  resource_group_name = data.azurerm_managed_disk.jenkins_os.resource_group_name

  create_option       = "Copy"
  source_resource_id  = data.azurerm_managed_disk.jenkins_os.id
}