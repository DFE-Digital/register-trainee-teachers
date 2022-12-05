variable "environment_name" {
  type = string
}

variable "backend_resource_group_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tempdata_storage_account_name" {
  default = null
}

variable "storage_account_replication_type" {
  type = string
}

variable "region_name" {
  default = "west europe"
  type    = string
}

locals {
  hosting_environment = var.environment_name
}
