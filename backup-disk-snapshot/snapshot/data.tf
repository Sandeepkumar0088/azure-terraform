data "azurerm_managed_disk" "jenkins_os" {
  name                = "jenkins-osdisk"
  resource_group_name = "rg-almalinux"
}