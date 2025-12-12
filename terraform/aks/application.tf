module "web_application" {
  for_each = var.main_app

  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.app_docker_image
  command                = each.value.startup_command
  max_memory             = each.value.memory_max
  replicas               = each.value.replicas
  web_external_hostnames = var.gov_uk_host_names
  probe_path             = each.value.probe_path

  azure_resource_prefix   = var.azure_resource_prefix
  service_short           = var.service_short
  kubernetes_cluster_id   = module.cluster_data.kubernetes_id
  enable_logit            = var.enable_logit

  enable_prometheus_monitoring     = var.enable_prometheus_monitoring
  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page
  run_as_non_root                  = var.run_as_non_root
}

module "worker_application" {
  for_each = var.worker_apps

  source = "./vendor/modules/aks//aks/application"

  name   = each.key
  is_web = false

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = var.airbyte_enabled ? module.airbyte_application_configuration[0].kubernetes_secret_name : module.application_configuration.kubernetes_secret_name

  docker_image    = var.app_docker_image
  command         = each.value.startup_command
  max_memory      = each.value.memory_max
  replicas        = each.value.replicas
  probe_command   = each.value.probe_command
  enable_logit    = var.enable_logit
  enable_gcp_wif  = var.enable_gcp_wif
  run_as_non_root = var.run_as_non_root
}

module "application_configuration" {

  source = "./vendor/modules/aks//aks/application_configuration"

  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  config_variables      = local.app_env_values
  secret_variables      = local.app_secrets
}

module "airbyte_application_configuration" {

  count = var.airbyte_enabled ? 1 : 0

  source = "./vendor/modules/aks//aks/application_configuration"

  namespace             = var.namespace
  environment           = "${local.app_name_suffix}-ab"
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  config_variables      = local.app_env_values
  secret_variables      = local.airbyte_app_secrets
}
