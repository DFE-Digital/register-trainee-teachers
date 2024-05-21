# The following code imports the Azure module which just creates the temporary data storage account.

module "azure" {
 source = "../modules/azure"

 environment_name                         = var.app_environment
 resource_group_name                      = var.azure_resource_group_name
 tempdata_storage_account_name            = var.azure_tempdata_storage_account_name
 storage_account_replication_type         = var.azure_storage_account_replication_type
 region_name                              = var.azure_region_name
 backend_resource_group_name              = var.azure_resource_group_name
 deploy_temp_data_storage_account         = var.deploy_temp_data_storage_account
 virtual_network_name                     = var.virtual_network_name
}
