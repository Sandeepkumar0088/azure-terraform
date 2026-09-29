resource "azurerm_managed_disk" "restored_os" {
  name                = "${var.new_vm_name}-os-disk"
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_type = "Standard_LRS"
  create_option        = "Copy"

  source_resource_id = data.azurerm_snapshot.nginx.id

  disk_size_gb = data.azurerm_snapshot.nginx.disk_size_gb
}