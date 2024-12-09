output "storage_account_key" {
  value     = var.deploy_temp_data_storage_account ? azurerm_storage_account.tempdata[0].primary_access_key : ""
  sensitive = true
}
