resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = azurerm_resource_group.backup.name

  recovery_vault_name = azurerm_recovery_services_vault.backup.name

  source_vm_id = data.azurerm_virtual_machine.vm.id

  backup_policy_id = azurerm_backup_policy_vm.daily.id
}