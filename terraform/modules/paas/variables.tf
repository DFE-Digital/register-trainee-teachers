variable app_environment {}

variable app_docker_image {}

variable app_start_timeout { default = 300 }

variable postgres_service_plan {}

variable redis_service_plan {}

variable space_name {}

variable web_app_deployment_strategy { default = "blue-green-v2" }

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
  postgres_service_name    = "register-postgres-${var.app_environment}"
  redis_service_name       = "register-redis-${var.app_environment}"
  web_app_name             = "register-${var.app_environment}"
  web_app_start_command    = "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"
  app_environment          = merge(var.app_config_variable, var.app_secrets_variable)
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "register-worker-${var.app_environment}"
  logging_service_name     = "register-logit-${var.app_environment}"
  web_app_routes           = [cloudfoundry_route.web_app_service_gov_uk_route.id, cloudfoundry_route.web_app_route.id]
}
