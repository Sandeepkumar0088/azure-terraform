resource "azurerm_linux_virtual_machine" "restored" {
  name                = var.new_vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  network_interface_ids = [
    azurerm_network_interface.restored.id
  ]

  os_managed_disk_id = azurerm_managed_disk.restored_os.id
}