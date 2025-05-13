data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = local.app_resource_group_name
}

data "azurerm_key_vault_secret" "statuscake_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = var.key_vault_app_secret_name
}

data "azurerm_key_vault_secret" "infra_secrets" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = var.key_vault_infra_secret_name
}

data "azurerm_key_vault_secret" "ab_secrets" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = var.key_vault_ab_secret_name
}
