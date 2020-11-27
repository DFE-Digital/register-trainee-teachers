variable paas_user {}

variable paas_password {}

variable paas_sso_passcode {}

variable paas_app_environment {}

variable paas_space_name {}

variable paas_app_docker_image {}

variable paas_app_start_timeout {}

variable paas_postgres_service_plan {}

variable paas_redis_service_plan {}

variable paas_web_app_deployment_strategy { default = "blue-green-v2" }

variable paas_web_app_instances { default = 2 }

variable paas_web_app_memory { default = 512 }

variable paas_worker_app_instances { default = 2 }

variable paas_worker_app_memory { default = 512 }

variable paas_log_url {}

variable dockerhub_username {}

variable dockerhub_password {}

variable paas_app_config_file { default = "./terraform/workspace-variables/app_config.yml" }

variable paas_app_secrets_file { default = "./terraform/app_secrets.yml" }

#StatusCake
variable statuscake_alerts { type = map }
variable statuscake_username {}
variable statuscake_password {}

locals {
  paas_api_url = "https://api.london.cloud.service.gov.uk"
  app_secrets  = yamldecode(file(var.paas_app_secrets_file))

  app_config = yamldecode(file(var.paas_app_config_file))[var.paas_app_environment]

  docker_credentials = {
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}
