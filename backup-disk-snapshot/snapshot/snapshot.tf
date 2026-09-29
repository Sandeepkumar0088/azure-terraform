resource "azurerm_snapshot" "jenkins" {
  name                = "jenkins-os-snapshot"
  location            = data.azurerm_managed_disk.jenkins_os.location
  resource_group_name = data.azurerm_managed_disk.jenkins_os.resource_group_name

  create_option       = "Copy"
  source_resource_id  = data.azurerm_managed_disk.jenkins_os.id
}