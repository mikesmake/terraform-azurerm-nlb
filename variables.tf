variable "tenant_id" {
  type        = string
  description = "The tenant ID for the target subscription"
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID for the target deployment"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "key_vault_name" {
  type        = string
  description = "key_vault_name"
}

variable "vm_vnet_name" {
  type        = string
  description = "vm_vnet_name"
}

variable "vm_vnet_rg_name" {
  type        = string
  description = "Name of the resource group that hosts the VNET"
}


variable "nic_subnet_name" {
  type        = string
  description = "Name of the subnet to attach the VM to"
}


variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}

variable "active_directory_username" {
  type        = string
  description = "active_directory_username"
}

variable "active_directory_password" {
  type        = string
  description = "active_directory_password"
}


variable "sql1_number" {
  type        = number
  description = "SQL server VM name number"
}


variable "vm1_number" {
  type        = number
  description = "VM1 server VM name number"
}

variable "vm2_number" {
  type        = number
  description = "VM2 server VM name number"
}


variable "front_end_name" {
  type = string
}

variable "nlb_name" {
  type = string
}

variable "lb_backend_pool_name" {
  type = string
}

variable "health_probe_name" {
  type = string
}

variable "health_probe_port" {
  type = number
}

variable "rule_name" {
  type = string
}

variable "rule_protocol" {
  type    = string
  default = "TCP"
}

variable "frontend_port" {
  type    = number
  default = "80"
}

variable "backend_port" {
  type    = number
  default = "80"
}