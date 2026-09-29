variable "source_resource_group_name" {
  description = "Resource group containing the VM"
  type        = string
  default     = "devops54"
}

variable "vm_name" {
  description = "Existing VM to protect"
  type        = string
  default     = "devops-vm"
}

variable "backup_resource_group_name" {
  description = "Resource group for backup resources"
  type        = string
  default     = "backup-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}