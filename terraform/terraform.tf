terraform {
  required_version = "1.2.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.15.5"
    }

    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.4"
    }
  }
  backend "azurerm" {

  }
}

provider "cloudfoundry" {
  api_url           = local.paas_api_url
  user              = var.paas_sso_passcode == "" ? local.infra_secrets.CF_USER : null
  password          = var.paas_sso_passcode == "" ? local.infra_secrets.CF_PASSWORD : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = var.paas_sso_passcode != "" ? ".cftoken" : null
}


provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}


module "paas" {
  source = "./modules/paas"

  app_environment                   = var.paas_app_environment
  app_docker_image                  = var.paas_app_docker_image
  app_start_timeout                 = var.paas_app_start_timeout
  postgres_service_plan_13          = var.paas_postgres_service_plan_13
  postgres_snapshot_service_plan_13 = var.paas_postgres_snapshot_service_plan_13
  snapshot_databases_to_deploy      = var.paas_snapshot_databases_to_deploy
  redis_service_plan                = var.paas_redis_service_plan
  space_name                        = var.paas_space_name
  app_name                          = var.paas_app_name
  web_app_hostname                  = var.paas_web_app_hostname
  dttp_portal                       = var.paas_dttp_portal
  deployment_strategy               = var.paas_deployment_strategy
  web_app_instances                 = var.paas_web_app_instances
  web_app_memory                    = var.paas_web_app_memory
  worker_app_instances              = var.paas_worker_app_instances
  worker_app_memory                 = var.paas_worker_app_memory
  log_url                           = local.infra_secrets.LOGSTASH_URL
  app_secrets_variable              = local.app_secrets
  app_config_variable               = local.app_config
  worker_app_stopped                = var.paas_worker_app_stopped
  restore_from_db_guid              = var.paas_restore_from_db_guid
  db_backup_before_point_in_time    = var.paas_db_backup_before_point_in_time
}

#authenticate into provider
provider "statuscake" {
  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
}
# interface into statusCake module
module "statuscake" {
  source = "./modules/statuscake"
  alerts = var.statuscake_alerts
}

# The following code imports the Azure module which just creates the temporary data storage account.
# This is commented out because the CI pipeline service principal does not have sufficient permission
# to create Azure resources at present but we wanted to document the temporary data storage account
# in Terraform for when we migrate the service away from GOV.UK PaaS

# module "azure" {
#   source = "./modules/azure"

#   environment_name                         = var.paas_app_environment
#   resource_group_name                      = var.azure_resource_group_name
#   tempdata_storage_account_name            = var.azure_tempdata_storage_account_name
#   storage_account_replication_type         = var.azure_storage_account_replication_type
#   region_name                              = var.azure_region_name
#   backend_resource_group_name              = var.resource_group_name
# }
