variable "app_name_suffix" { default = null }

variable "app_name" { default = null }

# PaaS variables
variable "paas_sso_code" { default = "" }

variable "paas_app_environment" {}

variable "paas_app_docker_image" {}

variable "paas_snapshot_databases_to_deploy" { default = 0 }

variable "paas_clock_app_memory" { default = 512 }

variable "paas_worker_app_memory" { default = 512 }

variable "paas_clock_app_instances" { default = 1 }

variable "paas_worker_app_instances" { default = 1 }

variable "paas_worker_secondary_app_instances" { default = 1 }

variable "prometheus_app" { default = null }

# Key Vault variables
variable "azure_credentials" { default = null }

variable "key_vault_name" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

#variable "assets_host_names" {
#  default = []
#  type    = list(any)
#}

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

variable "db_sslmode" { default = "require" }

#variable "webapp_startup_command" { default = null }

variable "azure_resource_prefix" {}

variable "enable_alerting" { default = false }
variable "pg_actiongroup_name" { default = false }
variable "pg_actiongroup_rg" { default = false }

variable "webapp_memory_max" { default = "1Gi" }
variable "worker_memory_max" { default = "1Gi" }
variable "secondary_worker_memory_max" { default = "1Gi" }
variable "clock_worker_memory_max" { default = "1Gi" }
variable "webapp_replicas" { default = 1 }
variable "worker_replicas" { default = 1 }
variable "secondary_worker_replicas" { default = 1 }
variable "clock_worker_replicas" { default = 1 }
variable "postgres_flexible_server_sku" { default = "B_Standard_B1ms" }
variable "postgres_flexible_server_storage_mb" { default = 32768 }
variable "postgres_enable_high_availability" { default = false }
variable "redis_capacity" { default = 1 }
variable "redis_family" { default = "C" }
variable "redis_sku_name" { default = "Standard" }

variable "pdb_min_available" { default = null }
variable "postgres_version" { default = "11" }
variable "config_short" {}
variable "service_short" {}

variable paas_app_config_file { default = "workspace-variables/app_config.yml" }
variable env_config {}

variable "postgres_extensions" {
  default = null
}

variable "postgres_create_servicename_db" {
  default = false
}

variable "service_name" {}
variable "worker_apps" {
  type    = map(
    object({
      startup_command = optional(list(string), [])
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
      probe_path      = optional(list(string), [])
      replicas        = optional(number, 1)
      memory_max      = optional(string, "1Gi")
    })
  )
  default = {}
}

variable "probe_path" { default = [] }

locals {
  #app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.paas_app_environment (from apply)
  app_name_suffix  = var.app_name == null ? var.paas_app_environment : var.app_name

  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  app_config        = yamldecode(file(var.paas_app_config_file))[var.env_config]
#  app_env_values = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

# only works for dv_review_aks as review_aks is in the test cluster
#  base_url_env_var  = var.paas_app_environment == "review" ? var.cluster != "" ? { SETTINGS__BASE_URL = "https://register-${local.app_name_suffix}.${var.cluster}.development.teacherservices.cloud" } : { SETTINGS__BASE_URL = "https://register-${local.app_name_suffix}.${var.cluster}.test.teacherservices.cloud" } : {}
  base_url_env_var  = var.paas_app_environment == "review" ? { SETTINGS__BASE_URL = "https://register-${local.app_name_suffix}.${module.cluster_data.configuration_map.dns_zone_prefix}.teacherservices.cloud" } : {}

  app_env_values_from_yaml = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

  #review_url_vars = {
  #  "CUSTOM_HOSTNAME" = "register-${local.app_name_suffix}.test.teacherservices.cloud"
  #  "AUTHORISED_HOSTS" = "register-${local.app_name_suffix}.test.teacherservices.cloud"
  #}

  app_env_values = merge(
    local.app_env_values_from_yaml,
    local.base_url_env_var,
    local.app_config,
  #  var.app_name_suffix != null ? local.review_url_vars : {},
  #  sslmode not defined in register database.yml?
    { DB_SSLMODE = var.db_sslmode }
  )

  cluster_name = "${module.cluster_data.configuration_map.resource_prefix}-aks"
  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

#Possibly required for register

#variable paas_app_start_timeout {}

#variable paas_snapshot_databases_to_deploy { default = 0 }

#variable paas_dttp_portal {
#  default = []
#  type = list
#}

#variable paas_app_config_file { default = "workspace-variables/app_config.yml" }

#variable env_config {}

#variable paas_restore_from_db_guid {
#  default = ""
#}

#variable paas_db_backup_before_point_in_time {
#  default = ""
#}

# "env_config": "review",

# "paas_app_start_timeout": 180,

# Azure Resource Variables

### variable resource_group_name {}

variable azure_resource_group_name {}

variable azure_tempdata_storage_account_name {}

variable azure_storage_account_replication_type { default = "LRS"}

variable azure_region_name { default = "uk south" }
