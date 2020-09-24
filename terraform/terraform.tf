terraform {
  required_version = "= 0.12.29"

  backend "azurerm" {
  }
}

provider azurerm {
  version = "=2.20.0"
}

provider cloudfoundry {
  api_url      = local.paas_api_url
  user         = var.paas_user != "" ? var.paas_user : null
  password     = var.paas_password != "" ? var.paas_password : null
  sso_passcode = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  version      = "~> 0.12"
}

module paas {
  source = "./modules/paas"

  app_environment             = var.paas_app_environment
  app_docker_image            = var.paas_app_docker_image
  app_start_timeout           = var.paas_app_start_timeout
  postgres_service_plan       = var.paas_postgres_service_plan
  redis_service_plan          = var.paas_redis_service_plan
  space_name                  = var.paas_space_name
  web_app_deployment_strategy = var.paas_web_app_deployment_strategy
  web_app_instances           = var.paas_web_app_instances
  web_app_memory              = var.paas_web_app_memory
  worker_app_instances        = var.paas_worker_app_instances
  worker_app_memory           = var.paas_worker_app_memory
  log_url                     = var.paas_log_url

  settings__basic_auth__username = var.paas_settings__basic_auth__username
  settings__basic_auth__password = var.paas_settings__basic_auth__password
  settings__dttp__client_id      = var.paas_settings__dttp__client_id
  settings__dttp__tenant_id      = var.paas_settings__dttp__tenant_id
  settings__dttp__client_secret  = var.paas_settings__dttp__client_secret
  settings__dttp__api_base_url   = var.paas_settings__dttp__api_base_url
}
