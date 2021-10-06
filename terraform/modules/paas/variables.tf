variable app_environment {}

variable app_docker_image {}

variable app_start_timeout { default = 300 }

variable postgres_service_plan {}

variable redis_service_plan {}

variable space_name {}

variable deployment_strategy { default = "blue-green-v2" }

variable web_app_hostname {}

variable web_app_instances { default = 1 }

variable web_app_memory { default = 512 }

variable worker_app_instances { default = 1 }

variable worker_app_memory { default = 512 }

variable log_url {}

variable docker_credentials { type = map }

variable app_secrets_variable { type = map } #secrets from yml file

variable app_config_variable { type = map } #from yml file

variable worker_app_stopped { default = false }

locals {
  app_name_suffix           = var.app_environment != "review" ? var.app_environment : "pr-${var.web_app_hostname}"
  postgres_service_name     = "register-postgres-${local.app_name_suffix}"
  redis_worker_service_name = "register-redis-worker-${local.app_name_suffix}"
  redis_cache_service_name  = "register-redis-cache-${local.app_name_suffix}"
  web_app_name              = "register-${local.app_name_suffix}"
  app_environment = merge(var.app_config_variable, var.app_secrets_variable, {
    SETTINGS__BLAZER_DATABASE_URL = cloudfoundry_service_key.postgres-blazer-key.credentials.uri
  })
  review_app_start_command = "bundle exec rake db:migrate db:seed example_data:generate && bundle exec rails server -b 0.0.0.0"
  web_app_start_command    = var.app_environment == "review" ? local.review_app_start_command : "bundle exec rails db:migrate:with_data_migrations && bundle exec rails server -b 0.0.0.0"
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "register-worker-${local.app_name_suffix}"
  logging_service_name     = "register-logit-${local.app_name_suffix}"
  web_app_routes           = [cloudfoundry_route.web_app_service_gov_uk_route.id, cloudfoundry_route.web_app_route.id]
  noeviction_maxmemory_policy = {
    maxmemory_policy = "noeviction"
  }
  allkeys_lru_maxmemory_policy = {
    maxmemory_policy = "allkeys-lru"
  }
  postgres_params = {
    enable_extensions = ["pgcrypto"]
  }
}
