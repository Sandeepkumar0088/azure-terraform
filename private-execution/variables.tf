variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

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
  default     = "azureuser"
}

variable "admin_password" {
  description = "Linux administrator password"
  type        = string
  sensitive   = true
}

variable "management_cidr" {
  description = "Public IP of management server in CIDR format"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "almalinux_publisher" {
  description = "AlmaLinux image publisher"
  type        = string
  default     = "almalinux"
}

variable "almalinux_offer" {
  description = "AlmaLinux image offer"
  type        = string
}

variable "almalinux_sku" {
  description = "AlmaLinux image SKU"
  type        = string
}

variable "almalinux_version" {
  description = "AlmaLinux image version"
  type        = string
  default     = "latest"
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
