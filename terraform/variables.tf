variable paas_user { default = null }

variable paas_password { default = null }

variable paas_sso_passcode { default = null }

variable paas_app_environment {}

variable paas_space_name {}

variable paas_app_docker_image {}

variable paas_app_start_timeout {}

variable paas_postgres_service_plan {}

variable paas_redis_service_plan {}

variable paas_deployment_strategy { default = "blue-green-v2" }

variable paas_web_app_instances { default = 2 }

variable paas_web_app_memory { default = 512 }

variable paas_worker_app_instances { default = 2 }

variable paas_worker_app_memory { default = 512 }

variable dockerhub_username { default = null }

variable dockerhub_password { default = null }

variable paas_app_config_file { default = "workspace-variables/app_config.yml" }

variable paas_app_secrets_file { default = "workspace-variables/app_secrets.yml" }

variable infra_secrets_file { default = "workspace-variables/infra_secrets.yml" }

variable env_config {}

variable paas_worker_app_stopped { default = false }

variable statuscake_alerts { type = map }


locals {
  paas_api_url = "https://api.london.cloud.service.gov.uk"

  app_secrets   = yamldecode(file(var.paas_app_secrets_file))
  app_config    = yamldecode(file(var.paas_app_config_file))[var.env_config]
  infra_secrets = yamldecode(file(var.infra_secrets_file))

  docker_credentials = {
    username = var.dockerhub_username == null ? local.infra_secrets.dockerhub_username : var.dockerhub_username
    password = var.dockerhub_password == null ? local.infra_secrets.dockerhub_password : var.dockerhub_password
  }
}
