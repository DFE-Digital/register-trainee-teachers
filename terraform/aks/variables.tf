variable "postgres_version" { default = 13 }

variable "app_name" { default = null }

variable "app_environment" {}

variable "app_docker_image" {}

variable "snapshot_databases_to_deploy" { default = 0 }

# Key Vault variables
variable "key_vault_name" {}
variable "key_vault_infra_secret_name" {}
variable "key_vault_app_secret_name" {}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

# StatusCake variables
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

# Kubernetes variables
variable "namespace" {}

variable "cluster" {}

variable "deploy_azure_backing_services" { default = true }

variable "enable_monitoring" { default = true }

variable "db_sslmode" { default = "require" }

variable "azure_resource_prefix" {}

variable "alert_window_size" {
  default = "PT5M"
}

variable "config_short" {}
variable "service_short" {}

variable "app_config_file" { default = "workspace-variables/app_config.yml" }
variable "env_config" {}

variable "service_name" {}
variable "worker_apps" {
  type = map(
    object({
      startup_command = optional(list(string), [])
      probe_command   = optional(list(string), [])
      replicas        = optional(number, 1)
      memory_max      = optional(string, "1Gi")
    })
  )
  default = {}
}
variable "main_app" {
  type = map(
    object({
      startup_command = optional(list(string), [])
      probe_path      = optional(string, null)
      replicas        = optional(number, 1)
      memory_max      = optional(string, "1Gi")
    })
  )
  default = {}
}

variable "azure_maintenance_window" { default = null }
variable "postgres_flexible_server_sku" { default = "B_Standard_B1ms" }
variable "snapshot_flexible_server_sku" { default = "GP_Standard_D2ds_v4" }
variable "postgres_enable_high_availability" { default = false }
variable "azure_enable_backup_storage" { default = true }
variable "enable_container_monitoring" { default = false }
variable "enable_logit" { default = false }
variable "enable_gcp_wif" { default = true }

variable "enable_prometheus_monitoring" {
  type    = bool
  default = false
}

variable "azure_resource_group_name" { default = null }
variable "azure_tempdata_storage_account_name" { default = null }
variable "azure_storage_account_replication_type" { default = "LRS" }
variable "deploy_temp_data_storage_account" { default = true }
variable "enable_sanitised_storage" { default = false }

locals {
  app_name_suffix   = var.app_name == null ? var.app_environment : var.app_name

  kv_app_secrets    = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  app_config        = yamldecode(file(var.app_config_file))[var.env_config]
  base_url_env_var  = var.app_environment == "review" ? { SETTINGS__BASE_URL = "https://register-${local.app_name_suffix}.${module.cluster_data.configuration_map.dns_zone_prefix}.teacherservices.cloud" } : {}

  app_env_values = merge(
    local.base_url_env_var,
    local.app_config,
    {
      DB_SSLMODE                                  = var.db_sslmode
      SETTINGS__AZURE__STORAGE__TEMP_DATA_ACCOUNT = local.azure_tempdata_storage_account_name
    }
  )

  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  # added for app module

  app_secrets = merge(
    local.kv_app_secrets,
    {
      DATABASE_URL                                   = module.postgres.url
      SETTINGS__BLAZER_DATABASE_URL                  = module.postgres.url
      REDIS_QUEUE_URL                                = module.redis-queue.url
      REDIS_CACHE_URL                                = module.redis-cache.url
      SETTINGS__AZURE__STORAGE__TEMP_DATA_ACCESS_KEY = module.azure.storage_account_key
    },
    var.snapshot_databases_to_deploy == 1 ? { ANALYSIS_DATABASE_URL = module.postgres_snapshot[0].url } : {}
  )
  default_azure_tempdata_storage_account_name = replace("${var.azure_resource_prefix}${var.service_short}${local.app_name_suffix}tmp", "-", "")
  azure_tempdata_storage_account_name         = var.azure_tempdata_storage_account_name != null ? var.azure_tempdata_storage_account_name : local.default_azure_tempdata_storage_account_name
  azure_sanitised_storage_account_name        = "${var.azure_resource_prefix}${var.service_short}dbbkpsan${var.config_short}sa"
}
