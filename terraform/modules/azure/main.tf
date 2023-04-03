terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
  }
}

#resource "azurerm_resource_group" "app_group" {
#  name     = var.resource_group_name
#  location = var.region_name
#  tags     = data.azurerm_resource_group.backend_resource_group_name.tags
#}
