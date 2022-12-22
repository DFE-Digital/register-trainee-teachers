data "azurerm_resource_group" "group" {
  name  = azurerm_resource_group.app_group.name
}

data "azurerm_resource_group" "backend_resource_group_name" {
  name = var.backend_resource_group_name
}
