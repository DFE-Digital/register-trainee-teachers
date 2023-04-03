data "azurerm_resource_group" "group" {
  name  = var.backend_resource_group_name
}

#data "azurerm_resource_group" "backend_resource_group_name" {
#  name = var.backend_resource_group_name
#}
