variable app_environment {}

variable app_docker_image {}

variable app_start_timeout { default = 300 }

variable postgres_service_plan {}

variable postgres_snapshot_service_plan {}

variable snapshot_databases_to_deploy {}

variable redis_service_plan {}

variable space_name {}

variable deployment_strategy { default = "blue-green-v2" }

variable web_app_hostname {}

variable dttp_portal {
  default = []
  type = list
}

variable web_app_instances { default = 1 }

variable web_app_memory { default = 512 }

variable worker_app_instances { default = 1 }

variable worker_app_memory { default = 512 }

variable log_url {}

variable app_secrets_variable { type = map } #secrets from yml file

variable app_config_variable { type = map } #from yml file

variable worker_app_stopped { default = false }
variable app_name { default = null }

variable "restore_from_db_guid" {}

variable "db_backup_before_point_in_time" {}

locals {
  app_name_suffix                = var.app_name == null ? var.app_environment : var.app_name
  postgres_service_name          = "register-postgres-${local.app_name_suffix}"
  postgres_snapshot_service_name = "register-postgres-analysis"
  redis_worker_service_name      = "register-redis-worker-${local.app_name_suffix}"
  redis_cache_service_name       = "register-redis-cache-${local.app_name_suffix}"
  web_app_name                   = "register-${local.app_name_suffix}"
  base_url_env_var               = var.app_environment == "review" ? { SETTINGS__BASE_URL = "https://${local.web_app_name}.london.cloudapps.digital" } : {}
  app_environment = merge(var.app_config_variable, var.app_secrets_variable, {
    DATABASE_URL  = cloudfoundry_service_key.postgres-key.credentials.uri
    SETTINGS__BLAZER_DATABASE_URL = cloudfoundry_service_key.postgres-blazer-key.credentials.uri
  }, local.base_url_env_var)
  web_app_start_command    = "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "register-worker-${local.app_name_suffix}"
  logging_service_name     = "register-logit-${local.app_name_suffix}"
  web_app_routes           = flatten([
    cloudfoundry_route.web_app_route,
    values(cloudfoundry_route.web_app_education_gov_uk_route),
    values(cloudfoundry_route.web_app_dttp_gov_uk_route),
    values(cloudfoundry_route.web_app_service_gov_uk_route)
  ])
  noeviction_maxmemory_policy = {
    maxmemory_policy = "noeviction"
  }
  allkeys_lru_maxmemory_policy = {
    maxmemory_policy = "allkeys-lru"
  }
  postgres_backup_restore_params = var.restore_from_db_guid != "" && var.db_backup_before_point_in_time != "" ? {
    restore_from_point_in_time_of     = var.restore_from_db_guid
    restore_from_point_in_time_before = var.db_backup_before_point_in_time
  } : {}
  postgres_extensions = {
    enable_extensions = ["pgcrypto", "btree_gist"]
  }
  postgres_params = merge(local.postgres_backup_restore_params, local.postgres_extensions)
}
