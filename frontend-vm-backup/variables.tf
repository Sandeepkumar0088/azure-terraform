variable "resource_group_name" {
  type    = string
  default = "rg-almalinux"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vm_name" {
  type    = string
  default = "nginx"
}

variable "vault_name" {
  type    = string
  default = "nginx-backup-vault"
}

variable "backup_policy_name" {
  type    = string
  default = "nginx-daily-backup-policy"
}