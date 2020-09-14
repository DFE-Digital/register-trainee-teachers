variable paas_user {}

variable paas_password {}

variable paas_sso_passcode {}

variable paas_app_environment {}

variable paas_space_name {}

variable paas_app_docker_image {}

variable paas_app_start_timeout {}

variable paas_app_stopped { default = false }

variable paas_postgres_service_plan {}

variable paas_redis_service_plan {}

variable paas_web_app_deployment_strategy { default = "blue-green-v2" }

variable paas_web_app_instances { default = 2 }

variable paas_web_app_memory { default = 512 }

variable paas_worker_app_instances { default = 2 }

variable paas_worker_app_memory { default = 512 }


locals {
  pass_api_url = "https://api.london.cloud.service.gov.uk"
}
