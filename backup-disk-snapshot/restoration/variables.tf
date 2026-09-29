variable "resource_group_name" {
  type    = string
  default = "rg-almalinux"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "snapshot_name" {
  type    = string
  default = "nginx-os-snapshot"
}

variable "new_vm_name" {
  type    = string
  default = "nginx-restored"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ats_v2"
}