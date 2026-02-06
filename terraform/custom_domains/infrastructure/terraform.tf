terraform {

  required_version = "= 1.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}
