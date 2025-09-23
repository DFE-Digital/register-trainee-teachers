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

  curlCommand  = local.curlCommand
  docker_image = var.app_docker_image
  airbyte_db_config = var.airbyte_db_config

  sqlCommand = local.sqlCommand
  postgres_version = var.postgres_version
  postgres_url = module.postgres.url

}

locals {
  database_name = "${var.service_short}_${local.app_name_suffix}"

  name_suffix = var.name != null ? "-${var.name}" : ""

  template_variable_map = var.airbyte_db_config ? {
    repl_password  = data.azurerm_key_vault_secret.airbyte_replication_password.value
    database_name  = module.postgres.name
  } : {}

  template_variable_map_curl = var.airbyte_enabled ? {
    server_url         = data.azurerm_key_vault_secret.airbyte_server_url.value
    client_id          = data.azurerm_key_vault_secret.airbyte_client_id.value
    client_secret      = data.azurerm_key_vault_secret.airbyte_client_secret.value
    connection_id      = module.airbyte[0].connection_id
    connection_streams = local.connection_streams
  } : {}

  airbyte_full_url = var.airbyte_enabled ? "${data.azurerm_key_vault_secret.airbyte_server_url.value}/api/public/v1" : null

  connection_streams = var.airbyte_enabled ? file("workspace-variables/airbyte_stream_config.json") : null
  sqlCommand         = var.airbyte_db_config ? templatefile("${path.module}/workspace-variables/airbyte.sql.tmpl", local.template_variable_map) : null
  curlCommand        = var.airbyte_enabled ? templatefile("${path.module}/workspace-variables/airbyte.curl.tmpl", local.template_variable_map_curl) : null
  sql_secret_hash    = var.airbyte_db_config ? substr(sha1("${local.sqlCommand}"),0,12) : null
  stream_secret_hash = var.airbyte_db_config ? substr(sha1("${local.connection_streams}"),0,12) : null

}
