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

variable settings__basic_auth__username {}
variable settings__basic_auth__password {} #secrets

variable settings__dttp__client_id {}
variable settings__dttp__tenant_id {}
variable settings__dttp__client_secret {} #secrets
variable settings__dttp__api_base_url {}



locals {
  postgres_service_name = "register-postgres-${var.app_environment}"
  redis_service_name    = "register-redis-${var.app_environment}"
  web_app_name          = "register-${var.app_environment}"
  web_app_start_command = "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"
  app_environment = {
    AUTHORISED_HOSTS               = "${local.web_app_name}.london.cloudapps.digital"
    RAILS_ENV                      = "production"
    RACK_ENV                       = "production"
    RAILS_SERVE_STATIC_FILES       = true
    SECRET_KEY_BASE                = "TestKey"
    SETTINGS__BASIC_AUTH__USERNAME = var.settings__basic_auth__username
    SETTINGS__BASIC_AUTH__PASSWORD = var.settings__basic_auth__password

    SETTINGS__DTTP__CLIENT_ID     = var.settings__dttp__client_id
    SETTINGS__DTTP__TENANT_ID     = var.settings__dttp__tenant_id
    SETTINGS__DTTP__CLIENT_SECRET = var.settings__dttp__client_secret
    SETTINGS__DTTP__API_BASE_URL  = var.settings__dttp__api_base_url

  }
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "register-worker-${var.app_environment}"
  logging_service_name     = "register-logit-${var.app_environment}"
}
