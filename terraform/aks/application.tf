module "web_application" {
  for_each = var.main_app

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=main"

  is_web = true

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = kubernetes_config_map.app_config.metadata[0].name
  kubernetes_secret_name     = kubernetes_secret.app_secrets.metadata[0].name

  docker_image = var.paas_app_docker_image
  command     = each.value.startup_command
  max_memory  = each.value.memory_max
  replicas    = each.value.replicas
  web_external_hostnames = var.gov_uk_host_names
  probe_path  = each.value.probe_path
}

module "worker_application" {
  for_each = var.worker_apps

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=main"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = kubernetes_config_map.app_config.metadata[0].name
  kubernetes_secret_name     = kubernetes_secret.app_secrets.metadata[0].name

  docker_image = var.paas_app_docker_image
  command     = each.value.startup_command
  max_memory  = each.value.memory_max
  replicas    = each.value.replicas
  probe_command = each.value.probe_command
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${var.service_name}-config-${local.app_name_suffix}-${local.app_env_values_hash}"
    namespace = var.namespace
  }
  data = local.app_env_values
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "${var.service_name}-secrets-${local.app_name_suffix}-${local.app_secrets_hash}"
    namespace = var.namespace
  }
  data = local.app_secrets
}
