variable "resource_group_name" {
  type    = string
  default = "frontend-rg"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vm_name" {
  type    = string
  default = "jenkins"
}

variable "vault_name" {
  type    = string
  default = "frontend-backup-vault"
}

variable "backup_policy_name" {
  type    = string
  default = "frontend-daily-backup-policy"
}