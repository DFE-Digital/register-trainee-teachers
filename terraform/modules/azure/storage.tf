resource "azurerm_storage_account" "tempdata" {
  count = var.review_app ? 0 : 1
  name                              = var.tempdata_storage_account_name
  resource_group_name               = var.backend_resource_group_name
  location                          = var.region_name
  account_replication_type          = var.storage_account_replication_type
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  depends_on = [data.azurerm_resource_group.group]
}

resource "azurerm_storage_container" "tempdata" {
  count = var.review_app ? 0 : 1
  name                  = "tempdata"
  storage_account_name  = var.tempdata_storage_account_name
  container_access_type = "private"
}
