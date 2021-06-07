variable paas_sso_passcode { default = null }

variable paas_app_environment {}

variable paas_space_name {}

variable paas_app_docker_image {}

variable paas_app_start_timeout {}

variable paas_postgres_service_plan {}

variable paas_redis_service_plan {}

variable paas_deployment_strategy { default = "blue-green-v2" }

variable paas_web_app_hostname {}

variable paas_web_app_instances { default = 2 }

variable paas_web_app_memory { default = 512 }

variable paas_worker_app_instances { default = 2 }

variable paas_worker_app_memory { default = 512 }

variable paas_app_config_file { default = "workspace-variables/app_config.yml" }

variable env_config {}

variable paas_worker_app_stopped { default = false }

variable statuscake_alerts {
  type    = map
  default = {}
}

variable key_vault_name {}

variable key_vault_resource_group {}

variable key_vault_app_secret_name {}

variable key_vault_infra_secret_name {}

variable azure_credentials { default = null }


locals {
  paas_api_url  = "https://api.london.cloud.service.gov.uk"
  app_secrets   = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  app_config    = yamldecode(file(var.paas_app_config_file))[var.env_config]
  docker_credentials = {
    username = local.infra_secrets.DOCKERHUB_USERNAME
    password = local.infra_secrets.DOCKERHUB_PASSWORD
  }

  azure_credentials = try(jsondecode(var.azure_credentials), null)
}
