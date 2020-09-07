terraform {
  required_version = "= 0.12.29"

  backend "azurerm" {
  }
}

provider azurerm {
  version = "=2.20.0"
}

provider cloudfoundry {
  api_url      = local.pass_api_url
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
  app_stopped                 = var.paas_app_stopped
  postgres_service_plan       = var.paas_postgres_service_plan
  redis_service_plan          = var.paas_redis_service_plan
  space_name                  = var.paas_space_name
  web_app_deployment_strategy = var.paas_web_app_deployment_strategy
  web_app_instances           = var.paas_web_app_instances
  web_app_memory              = var.paas_web_app_memory
}
