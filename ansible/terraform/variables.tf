variable "resource_group_name" {
  description = "Name of the existing Azure resource group"
  type        = string
  default     = "test-iot"
}

variable "bastion_private_ip" {
  description = "Private IP address of the bastion VM"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Linux VM administrator username"
  type        = string
  default     = "ubuntu"
}
variable "admin_password" {
  description = "Ubuntu administrator password"
  type        = string
  sensitive   = true
  default     = "Sandeep.,@0088"
}