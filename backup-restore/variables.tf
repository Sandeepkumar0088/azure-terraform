variable "source_resource_group_name" {
  description = "Resource group containing the VM"
  type        = string
  default     = "rg-almalinux"
}

variable "vm_name" {
  description = "Existing VM to protect"
  type        = string
  default     = "jenkins"
}

variable "backup_resource_group_name" {
  description = "Resource group for backup resources"
  type        = string
  default     = "backed-up"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}