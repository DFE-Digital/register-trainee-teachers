module "redis-cache" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "cache"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_patch_schedule    = [{ "day_of_week": "Sunday", "start_hour_utc": 01 }]
}

module "redis-queue" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "queue"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_maxmemory_policy  = "noeviction"
  azure_patch_schedule    = [{ "day_of_week": "Sunday", "start_hour_utc": 01 }]
}

module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"

  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  use_airbyte      = var.airbyte_enabled

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_extensions        = ["PGCRYPTO","BTREE_GIST","CITEXT","PG_TRGM"]
  server_version          = var.postgres_version
  azure_sku_name          = var.postgres_flexible_server_sku

  azure_enable_high_availability = var.postgres_enable_high_availability
  azure_maintenance_window       = var.azure_maintenance_window
  azure_enable_backup_storage    = var.azure_enable_backup_storage
}

module "postgres_snapshot" {
  count = var.snapshot_databases_to_deploy

  source = "./vendor/modules/aks//aks/postgres"

  name                  = "analysis"
  namespace             = var.namespace
  environment           = "analysis"
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = true
  azure_enable_monitoring = var.enable_monitoring
  alert_window_size       = var.alert_window_size
  azure_extensions        = ["PGCRYPTO","BTREE_GIST","CITEXT","PG_TRGM"]
  server_version          = var.postgres_version
  azure_sku_name          = var.snapshot_flexible_server_sku

  azure_enable_high_availability      = false
  azure_maintenance_window            = var.azure_maintenance_window
  azure_enable_backup_storage         = false
}
