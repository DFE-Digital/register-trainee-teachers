# The following code imports the Azure module which just creates the temporary data storage account.

module "azure" {
  source = "../modules/azure"

  resource_group_name              = var.azure_resource_group_name
  tempdata_storage_account_name    = local.azure_tempdata_storage_account_name
  storage_account_replication_type = var.azure_storage_account_replication_type
  deploy_temp_data_storage_account = var.deploy_temp_data_storage_account
  sanitised_storage_account_name   = local.azure_sanitised_storage_account_name
  enable_sanitised_storage         = var.enable_sanitised_storage
}
