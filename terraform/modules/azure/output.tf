output "storage_account_key" {
  value = azurerm_storage_account.tempdata[0].primary_access_key
}
