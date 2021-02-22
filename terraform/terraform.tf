terraform {
  required_version = "~> 0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.45.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
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
  user              = try(local.infra_secrets.CF_USER, null)
  password          = try(local.infra_secrets.CF_PASSWORD, null)
  sso_passcode      = var.paas_sso_passcode
  store_tokens_path = "tokens"
  version           = "~> 0.12"
}


provider azurerm {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}


module paas {
  source = "./modules/paas"

  app_environment       = var.paas_app_environment
  app_docker_image      = var.paas_app_docker_image
  app_start_timeout     = var.paas_app_start_timeout
  postgres_service_plan = var.paas_postgres_service_plan
  redis_service_plan    = var.paas_redis_service_plan
  space_name            = var.paas_space_name
  deployment_strategy   = var.paas_deployment_strategy
  web_app_instances     = var.paas_web_app_instances
  web_app_memory        = var.paas_web_app_memory
  worker_app_instances  = var.paas_worker_app_instances
  worker_app_memory     = var.paas_worker_app_memory
  log_url               = local.infra_secrets.LOGSTASH_URL
  docker_credentials    = local.docker_credentials
  app_secrets_variable  = local.app_secrets
  app_config_variable   = local.app_config
  worker_app_stopped    = var.paas_worker_app_stopped
}

#authenticate into provider
provider statuscake {
  username = local.infra_secrets.STATUSCAKE_USERNAME
  apikey   = local.infra_secrets.STATUSCAKE_PASSWORD
}
# interface into statusCake module
module statuscake {
  source = "./modules/statuscake"
  alerts = var.statuscake_alerts
}
