provider "google" {
  project = "rugged-abacus-218110"
}

data "azurerm_key_vault_secret" "airbyte_client_id" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-ID"
}

data "azurerm_key_vault_secret" "airbyte_client_secret" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-SECRET"
}

data "azurerm_key_vault_secret" "airbyte_workspace_id" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-WORKSPACE-ID"
}

# change this to a random password?
data "azurerm_key_vault_secret" "airbyte_replication_password" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-REPLICATION-PASSWORD"
}

module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = var.service_name
  docker_image          = var.app_docker_image
  postgres_version      = var.postgres_version
  postgres_url          = module.postgres.url

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = data.azurerm_key_vault_secret.airbyte_workspace_id[0].value
  client_id          = data.azurerm_key_vault_secret.airbyte_client_id[0].value
  client_secret      = data.azurerm_key_vault_secret.airbyte_client_secret[0].value
  repl_password      = data.azurerm_key_vault_secret.airbyte_replication_password[0].value
  server_url         = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
  connection_status  = var.connection_status
  connection_streams = local.connection_streams

  cluster           = var.cluster
  namespace         = var.namespace
  gcp_taxonomy_id   = "69524444121704657"
  gcp_policy_tag_id = "6523652585511281766"
  gcp_keyring       = "bat-key-ring"
  gcp_key           = "bat-key"

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
}

module "streams_update_job" {
  source = "./vendor/modules/aks//aks/job_configuration"

  count = var.airbyte_enabled ? 1 : 0

  depends_on = [module.airbyte]

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name
  docker_image = var.app_docker_image
  commands     = ["/bin/sh"]
  arguments    = ["-c", "rake dfe:analytics:airbyte_deploy_tasks"]
  job_name     = "airbyte-stream-update"
  enable_logit = true

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.airbyte_application_configuration[0].kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min
}

## Airbyte module variables

variable "airbyte_enabled" { default = false }

variable "connection_status" {
  type = string
  default = "inactive"
  description = "Connectin status, either active or inactive"
}

locals {
  connection_streams = var.airbyte_enabled ? file("workspace-variables/airbyte_stream_config.json") : null
  gcp_dataset_name   = replace("${var.service_short}_airbyte_${local.app_name_suffix}", "-", "_")
}
