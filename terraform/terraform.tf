terraform {
  required_version = "~> 0.13.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.29.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }

    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "1.0.0"
    }
  }
  backend azurerm {

  }
}

provider cloudfoundry {
  api_url           = local.paas_api_url
  user              = var.paas_user == null ? local.infra_secrets.paas_user : var.paas_user
  password          = var.paas_password == null ? local.infra_secrets.paas_password : var.paas_password
  sso_passcode      = var.paas_sso_passcode
  store_tokens_path = "./terraform/tokens"
  version           = "~> 0.12"
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
  log_url                     = local.infra_secrets.paas_log_url
  docker_credentials          = local.docker_credentials
  app_secrets_variable        = local.app_secrets
  app_config_variable         = local.app_config
}

#authenticate into provider
provider statuscake {
  username = var.statuscake_user == null ? local.infra_secrets.statuscake_username : var.statuscake_user
  apikey   = var.statuscake_password == null ? local.infra_secrets.statuscake_password : var.statuscake_password
}
# interface into statusCake module
module statuscake {
  source = "./modules/statuscake"
  alerts = var.statuscake_alerts
}
