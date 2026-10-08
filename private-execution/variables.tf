variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-roboshop-private"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "admin_username" {
  description = "Linux administrator username"
  type        = string
  default     = "sandeep"
}

variable "admin_password" {
  description = "Linux administrator password"
  type        = string
  default     = "Sandeep.,@0088"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}



variable "private_vm_ips" {
    default = {
        frontend    = "Standard_B2ats_v2"
        mongodb     = "Standard_B2ats_v2"
        catalogue   = "Standard_B2ats_v2"
        user        = "Standard_B2ats_v2"
        redis       = "Standard_B2ats_v2"
        cart        = "Standard_B2ats_v2"
        mysql       = "Standard_D4ls_v6"
        shipping    = "Standard_B2ats_v2"
        rabbitmq    = "Standard_B2ats_v2"
        payment     = "Standard_B2ats_v2"
    }
}
