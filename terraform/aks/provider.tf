terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.10.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

provider "statuscake" {
  api_token = data.azurerm_key_vault_secret.statuscake_password.value
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = module.cluster_data.kubelogin_args
  }
}

provider "airbyte" {
  # Configuration options
  server_url = var.airbyte_enabled ? "${data.azurerm_key_vault_secret.airbyte_server_url.value}/api/public/v1" : ""
  client_id = var.airbyte_enabled ? data.azurerm_key_vault_secret.airbyte_client_id.value : ""
  client_secret = var.airbyte_enabled ? data.azurerm_key_vault_secret.airbyte_client_secret.value: ""
}
