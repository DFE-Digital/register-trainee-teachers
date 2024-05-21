variable "app_name_suffix" { default = null }

variable "postgres_version" { default = 13 }

variable "app_name" { default = null }

# PaaS variables

variable "app_environment" {}

variable "app_docker_image" {}

variable "snapshot_databases_to_deploy" { default = 0 }

# Key Vault variables
variable "azure_credentials" { default = null }

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

variable "api_token" { default = "" }

# Restore DB variables
variable "paas_restore_db_from_db_instance" { default = "" }

variable "paas_restore_db_from_point_in_time_before" { default = "" }

variable "paas_enable_external_logging" { default = true }

# Kubernetes variables
variable "namespace" {}

variable "cluster" {}

variable "deploy_azure_backing_services" { default = true }

variable "enable_monitoring" { default = true }

variable "db_sslmode" { default = "require" }

variable "azure_resource_prefix" {}

variable "enable_alerting" { default = false }
variable "pg_actiongroup_name" { default = false }
variable "pg_actiongroup_rg" { default = false }

variable "alert_window_size" {
  default = "PT5M"
}

variable "pdb_min_available" { default = null }
variable "config_short" {}
variable "service_short" {}

variable app_config_file { default = "workspace-variables/app_config.yml" }
variable env_config {}

variable "service_name" {}
variable "worker_apps" {
  type    = map(
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
  type    = map(
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
variable "postgres_enable_high_availability" { default = false }
variable "azure_enable_backup_storage" { default = true }
variable "enable_container_monitoring" { default = false }

locals {
  app_name_suffix  = var.app_name == null ? var.app_environment : var.app_name

  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  kv_app_secrets    = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  app_config        = yamldecode(file(var.app_config_file))[var.env_config]
  base_url_env_var  = var.app_environment == "review" ? { SETTINGS__BASE_URL = "https://register-${local.app_name_suffix}.${module.cluster_data.configuration_map.dns_zone_prefix}.teacherservices.cloud" } : {}

  app_env_values = merge(
    local.base_url_env_var,
    local.app_config,
    { DB_SSLMODE = var.db_sslmode }
  )

  cluster_name = "${module.cluster_data.configuration_map.resource_prefix}-aks"
  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  # added for app module

  app_secrets = merge(
    local.kv_app_secrets,
    {
      DATABASE_URL                    = module.postgres.url
      SETTINGS__BLAZER_DATABASE_URL   = module.postgres.url
      REDIS_QUEUE_URL                 = module.redis-queue.url
      REDIS_CACHE_URL                 = module.redis-cache.url
    },
    var.snapshot_databases_to_deploy == 1 ? { ANALYSIS_DATABASE_URL = module.postgres_snapshot[0].url } : {}
  )
}

variable azure_resource_group_name { default = null }

variable azure_tempdata_storage_account_name { default = null }

variable azure_storage_account_replication_type { default = "LRS" }

variable azure_region_name { default = "uk south" }

variable "deploy_temp_data_storage_account" { default = true }

variable "virtual_network_name" { default = "s189d01-tsc-cluster3-vnet" }

