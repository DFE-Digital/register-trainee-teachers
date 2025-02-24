variable "resource_group_name" {
  type = string
}

variable "tempdata_storage_account_name" {
  default = null
}

variable "storage_account_replication_type" {
  type = string
}

variable "deploy_temp_data_storage_account" { default = true }

variable "sanitised_storage_account_name" { default = null }

variable "enable_sanitised_storage" { default = false }
