module "kubernetes" {
  source = "../modules/kubernetes"

  app_docker_image                    = var.paas_app_docker_image
  app_environment                     = local.app_name_suffix
  app_environment_variables           = local.app_env_values
  app_secrets                         = local.app_secrets
  cluster                             = var.cluster
  deploy_azure_backing_services       = var.deploy_azure_backing_services
  namespace                           = var.namespace
  postgres_admin_password             = local.infra_secrets.POSTGRES_ADMIN_PASSWORD
  postgres_admin_username             = local.infra_secrets.POSTGRES_ADMIN_USERNAME
  app_resource_group_name             = local.app_resource_group_name
  azure_resource_prefix               = var.azure_resource_prefix
  postgres_flexible_server_sku        = var.postgres_flexible_server_sku
  postgres_flexible_server_storage_mb = var.postgres_flexible_server_storage_mb
  postgres_enable_high_availability   = var.postgres_enable_high_availability
  redis_capacity                      = var.redis_capacity
  redis_family                        = var.redis_family
  redis_sku_name                      = var.redis_sku_name
  gov_uk_host_names                   = var.gov_uk_host_names
  pg_actiongroup_name                 = var.pg_actiongroup_name
  pg_actiongroup_rg                   = var.pg_actiongroup_rg
  enable_alerting                     = var.enable_alerting
  pdb_min_available                   = var.pdb_min_available
  postgres_version                    = var.postgres_version
  config_short                        = var.config_short
  service_short                       = var.service_short
####  app_config_variable                 = local.app_config
  service_name                        = var.service_name
  postgres_create_servicename_db      = var.postgres_create_servicename_db
  postgres_extensions                 = var.postgres_extensions
  probe_path                          = var.probe_path
  worker_apps                         = var.worker_apps
  main_app                            = var.main_app
}

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
