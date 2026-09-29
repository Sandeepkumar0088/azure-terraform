resource "azurerm_virtual_machine" "restored" {
  name                = var.new_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_size             = var.vm_size

  network_interface_ids = [
    azurerm_network_interface.restore.id
  ]

  storage_os_disk {
    name              = azurerm_managed_disk.restored_os.name
    managed_disk_id   = azurerm_managed_disk.restored_os.id
    create_option     = "Attach"
    caching           = "ReadWrite"
    os_type           = "Linux"
  }

  delete_os_disk_on_termination = false
}