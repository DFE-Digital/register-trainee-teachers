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

variable "spn_authentication" {
  default = false
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  dynamic "exec" {
    for_each = module.cluster_data.azure_RBAC_enabled ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = module.cluster_data.kubelogin_args
    }
  }

}
