module "redis-cache" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "cache"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

module "redis-queue" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "queue"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_maxmemory_policy  = "noeviction"

}
