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

variable paas_settings__basic_auth__username {} #secrets
variable paas_settings__basic_auth__password {} #secrets
variable paas_settings__dttp__client_id {}      #secrets
variable paas_settings__dttp__tenant_id {}      #secrets
variable paas_settings__dttp__client_secret {}  # secrets
variable paas_settings__dttp__api_base_url {}   #secrets

locals {
  paas_api_url = "https://api.london.cloud.service.gov.uk"
}
