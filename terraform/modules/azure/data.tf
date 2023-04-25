data "azurerm_resource_group" "group" {
  count = var.deploy_temp_data_storage_account ? 1 : 0
  name  = var.backend_resource_group_name
}

#data "azurerm_resource_group" "backend_resource_group_name" {
#  name = var.backend_resource_group_name
#}
