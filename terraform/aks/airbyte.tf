
module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = local.ab_secrets.workspace_id

  use_airbyte      = var.airbyte_enabled
  repl_user        = local.ab_secrets.repl_user
  repl_password    = local.ab_secrets.repl_password
  dataset_id       = local.ab_secrets.dataset_id
  project_id       = local.ab_secrets.project_id
  credentials_json = local.ab_secrets.credentials_json

  connection_status = var.connection_status
  server_url        = local.ab_secrets.server_url

}

module "job_configuration" {
  source = "./vendor/modules/aks//aks/job_configuration"

  count = var.airbyte_enabled ? 1 : 0

  namespace              = var.namespace
  environment            = local.app_name_suffix
  service_name           = var.service_name
  docker_image           = "ghcr.io/dfe-digital/teacher-services-cloud:curl-3.21.3"
  commands               = ["/bin/sh"]
  arguments              = ["-c", "curl --request PATCH --url ${local.ab_secrets.server_url}/connections/${module.airbyte[0].connection_id} --header 'accept: application/json' --header 'content-type: application/json' --data '${local.connection_streams}'" ]
  job_name               = "airbyte-streams-config"
  enable_logit           = var.enable_logit

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

}

resource "kubernetes_secret" "airbyte-sql" {
  count = var.airbyte_db_config ? 1 : 0

  metadata {
    name      = "airbyte-sql-${local.secret_hash}"
    namespace = var.namespace
  }
  data = {
    "sqlCommand.sql" = local.sqlCommand
  }
}

resource "kubernetes_job" "airbyte-database-setup" {

  count = var.airbyte_db_config ? 1 : 0

  metadata {
    name      = "${var.service_name}-${local.app_name_suffix}-ab-db-setup-${kubernetes_secret.airbyte-sql[0].metadata[0].name}"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {
        labels = { app = "${var.service_name}-${local.app_name_suffix}-ab-db-setup" }
        annotations = {
          "logit.io/send"        = "true"
          "fluentbit.io/exclude" = "true"
        }
      }

      spec {
        container {
          name    = "airbyte-db-config"
          image   = "postgres:${var.postgres_version}-alpine"
          command = ["psql"]
          args    = ["-d", "${module.postgres.url}", "-f", "${var.sqlCommand}" ]

          volume_mount {
            name = "airbyte-sql"
            mount_path = "/airbyte"
          }

          env_from {
            config_map_ref {
              name = module.application_configuration.kubernetes_config_map_name
            }
          }

          env_from {
            secret_ref {
              name = module.application_configuration.kubernetes_secret_name
            }
          }

          resources {
            requests = {
              cpu    = module.cluster_data.configuration_map.cpu_min
              memory = "1Gi"
            }
            limits = {
              cpu    = 1
              memory = "1Gi"
            }
          }

         security_context {
            allow_privilege_escalation = false

            seccomp_profile {
              type = "RuntimeDefault"
            }

            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
        }

        volume {
          name = "airbyte-sql"
          secret {
            secret_name = kubernetes_secret.airbyte-sql[0].metadata[0].name
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 1
  }

  wait_for_completion = true

  timeouts {
    create = "11m"
    update = "11m"
  }
}

# module "job_configuration" {
#   source = "./vendor/modules/aks//aks/job_configuration"

#   count = var.airbyte_db_config ? 1 : 0

#   namespace              = var.namespace
#   environment            = local.app_name_suffix
#   service_name           = var.service_name
#   docker_image           = "postgres:${var.postgres_version}-alpine"
#   commands               = ["psql"]
#   arguments              = ["-d", "${module.postgres.url}", "-c", "${local.ab_db_config_sql}" ]
#   job_name               = "airbyte-database-config"
#   enable_logit           = var.enable_logit

#   config_map_ref = module.application_configuration.kubernetes_config_map_name
#   secret_ref     = module.application_configuration.kubernetes_secret_name
#   cpu            = module.cluster_data.configuration_map.cpu_min

# }

# data "airbyte_workspace" "workspace" {
#   count = var.airbyte_enabled ? 1 : 0

#   workspace_id = local.ab_secrets.workspace_id
# }

locals {
  database_name = "${var.service_short}_${local.app_name_suffix}"

  name_suffix = var.name != null ? "-${var.name}" : ""

  template_variable_map = {
    repl_password  = local.ab_secrets.repl_password
    database_name  = module.postgres.name
  }

#  ab_db_config_sql      = var.airbyte_db_config ? file("workspace-variables/airbyte-db-config.sql") : null
  connection_streams = var.airbyte_enabled ? file("workspace-variables/${var.app_environment}_streams.json") : null
  ab_secrets         = var.airbyte_enabled ? yamldecode(data.azurerm_key_vault_secret.ab_secrets[0].value) : null
  sqlCommand         = var.airbyte_db_config ? templatefile("${path.module}/workspace-variables/airbyte.sql.tmpl", local.template_variable_map) : null
  secret_hash        = var.airbyte_db_config ? substr(sha1("${local.sqlCommand}"),0,12) : null
}
