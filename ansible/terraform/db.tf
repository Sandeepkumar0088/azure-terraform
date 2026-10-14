resource "azurerm_linux_virtual_machine" "test_postgresql_vm" {
  name                = "ubuntu"
  computer_name       = "ubuntu"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2ats_v2"

  admin_username                  = "ubuntu"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  disk_controller_type = "SCSI"

  network_interface_ids = [
    azurerm_network_interface.private_vm.id
  ]

  os_disk {
    name                 = "ubuntu-private-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}


# resource "null_resource" "run_ansible" {
#   depends_on = [
#     azurerm_linux_virtual_machine.test_postgresql_vm
#   ]

#   connection {
#     type     = "ssh"
#     host     = azurerm_linux_virtual_machine.test_postgresql_vm.private_ip_address
#     user     = "ubuntu"
#     password = var.admin_password
#     timeout  = "5m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y ansible",
#       "cd /home/ubuntu",
#       "ansible-playbook ansible.yml"
#     ]
#   }
# }
