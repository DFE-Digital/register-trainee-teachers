provider "google" {
  project = var.project_id
}

data "azurerm_key_vault_secret" "airbyte_client_id" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-ID"
}

data "azurerm_key_vault_secret" "airbyte_client_secret" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-SECRET"
}

data "azurerm_key_vault_secret" "airbyte_server_url" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-SERVER-URL"
}

data "azurerm_key_vault_secret" "airbyte_workspace_id" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-WORKSPACE-ID"
}

# change this to a random password?
data "azurerm_key_vault_secret" "airbyte_replication_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-REPLICATION-PASSWORD"
}

module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = data.azurerm_key_vault_secret.airbyte_workspace_id.value
  client_id          = data.azurerm_key_vault_secret.airbyte_client_id.value
  client_secret      = data.azurerm_key_vault_secret.airbyte_client_secret.value

  use_airbyte      = var.airbyte_enabled
  repl_password    = data.azurerm_key_vault_secret.airbyte_replication_password.value
  project_id       = var.project_id

  connection_status = var.connection_status
  server_url        = data.azurerm_key_vault_secret.airbyte_server_url.value

  cluster               = var.cluster
  namespace             = var.namespace
  gcp_taxonomy_id       = "69524444121704657"
  gcp_policy_tag_id     = "6523652585511281766"
  gcp_keyring           = "bat-key-ring"
  gcp_key               = "bat-key"

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  docker_image       = var.app_docker_image
  airbyte_db_config  = var.airbyte_db_config
  postgres_version   = var.postgres_version
  postgres_url       = module.postgres.url
  connection_streams = local.connection_streams
}

locals {
  database_name      = "${var.service_short}_${local.app_name_suffix}"
  name_suffix        = var.name != null ? "-${var.name}" : ""
  connection_streams = var.airbyte_enabled ? file("workspace-variables/airbyte_stream_config.json") : null
}
