variable "app_environment" {}
variable "azure_region_name" {
  default = "uksouth"
}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_secrets" {}
variable "cluster" {}
variable "deploy_azure_backing_services" {}
variable "azure_resource_prefix" {}

variable "app_resource_group_name" {}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

# Variables for Azure alerts
variable "enable_alerting" {}
variable "pg_actiongroup_name" {}
variable "pg_actiongroup_rg" {}
variable "pg_memory_threshold" {
  default = 75
}
variable "pg_cpu_threshold" {
  default = 60
}
variable "pg_storage_threshold" {
  default = 75
}

variable "pdb_min_available" {
  type    = string
  default = null
}

variable "config_short" {}
variable "service_short" {}

# new for register

variable "service_name" {}

variable "worker_apps" {
  type    = map(any)
  default = {}
}
variable "main_app" {
  type    = map(any)
  default = {}
}
variable "probe_path" { default = [] }


variable "redis_cache_url" {}
variable "redis_queue_url" {}
variable "database_url" {}
# local.postgres_service_name

locals {
  app_config_name                      = "${var.service_name}-config-${var.app_environment}"
  app_secrets_name                     = "${var.service_name}-secrets-${var.app_environment}"
  backing_services_resource_group_name = "${local.current_cluster.cluster_resource_prefix}-bs-rg"
  hostname                             = local.current_cluster.dns_zone_prefix != null ? "${local.webapp_name}.${local.current_cluster.dns_zone_prefix}.teacherservices.cloud" : "${local.webapp_name}.teacherservices.cloud"

  webapp_name            = "${var.service_name}-${var.app_environment}"
  worker_name            = "${var.service_name}-worker-${var.app_environment}"

  cluster = {
    cluster1 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster1"
      dns_zone_prefix             = "cluster1.development"
      cpu_min                     = 0.1
    }
    cluster2 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster2"
      dns_zone_prefix             = "cluster2.development"
      cpu_min                     = 0.1
    }
    cluster3 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster3"
      dns_zone_prefix             = "cluster3.development"
      cpu_min                     = 0.1
    }
    cluster4 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster4"
      dns_zone_prefix             = "cluster4.development"
      cpu_min                     = 0.1
    }
    cluster5 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster5"
      dns_zone_prefix             = "cluster5.development"
      cpu_min                     = 0.1
    }
    cluster6 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster6"
      dns_zone_prefix             = "cluster6.development"
      cpu_min                     = 0.1
    }
    test = {
      cluster_resource_group_name = "s189t01-tsc-ts-rg"
      cluster_resource_prefix     = "s189t01-tsc-test"
      dns_zone_prefix             = "test"
      cpu_min                     = 0.1
    }
    platform-test = {
      cluster_resource_group_name = "s189t01-tsc-pt-rg"
      cluster_resource_prefix     = "s189t01-tsc-platform-test"
      dns_zone_prefix             = "platform-test"
      cpu_min                     = 0.1
    }
    production = {
      cluster_resource_group_name = "s189p01-tsc-pd-rg"
      cluster_resource_prefix     = "s189p01-tsc-production"
      dns_zone_prefix             = null
      cpu_min                     = 1
    }
  }
  current_cluster = local.cluster[var.cluster]
  cluster_name    = "${local.current_cluster.cluster_resource_prefix}-aks"
}
