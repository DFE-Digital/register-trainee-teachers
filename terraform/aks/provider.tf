terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}

provider "statuscake" {
  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
}
data "azurerm_client_config" "current" {
}

variable "spn_authentication" {
  default = false
}

variable "enable_azure_RBAC" {
  default = false
}

locals {
  kubelogin_args_map = {
    spn = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630"
    ],
    azurecli = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" # See https://azure.github.io/kubelogin/concepts/aks.html
    ]
  }

  kubelogin_args = var.spn_authentication ? local.kubelogin_args_map["spn"] : local.kubelogin_args_map["azurecli"]
}
provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate
  client_certificate     = var.enable_azure_RBAC ? null : module.cluster_data.kubernetes_client_certificate
  client_key             = var.enable_azure_RBAC ? null : module.cluster_data.kubernetes_client_key

  dynamic "exec" {
    for_each = var.enable_azure_RBAC ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = local.kubelogin_args
    }
  }

}
