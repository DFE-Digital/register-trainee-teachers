#module "statuscake" {
#  source = "../modules/statuscake"
#
#  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
#  alerts    = var.statuscake_alerts
#}

# The following code imports the Azure module which just creates the temporary data storage account.
# This is commented out because the CI pipeline service principal does not have sufficient permission
# to create Azure resources at present but we wanted to document the temporary data storage account
# in Terraform for when we migrate the service away from GOV.UK PaaS

module "azure" {
 source = "../modules/azure"

 environment_name                         = var.paas_app_environment
 resource_group_name                      = var.azure_resource_group_name
 tempdata_storage_account_name            = var.azure_tempdata_storage_account_name
 storage_account_replication_type         = var.azure_storage_account_replication_type
 region_name                              = var.azure_region_name
 backend_resource_group_name              = var.azure_resource_group_name
 deploy_temp_data_storage_account         = var.deploy_temp_data_storage_account
}
