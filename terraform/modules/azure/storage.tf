resource "azurerm_storage_account" "tempdata" {
  count = var.deploy_temp_data_storage_account ? 1 : 0
  name                              = var.tempdata_storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = data.azurerm_resource_group.group.location
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
}

resource "azurerm_storage_container" "tempdata" {
  count = var.deploy_temp_data_storage_account ? 1 : 0
  name                  = "tempdata"
  storage_account_name  = resource.azurerm_storage_account.tempdata[0].name
  container_access_type = "private"
}

resource "azurerm_storage_account" "sanitised_uploads" {
  count = var.enable_sanitised_storage ? 1 : 0

  name                              = var.sanitised_storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = "UK South"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false

  blob_properties {

    container_delete_retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "sanitised_uploads" {
  count                 = var.enable_sanitised_storage ? 1 : 0

  name                  = "database-backup"
  storage_account_name  = azurerm_storage_account.sanitised_uploads[0].name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "sanitised_backup" {
  count = var.enable_sanitised_storage ? 1 : 0

  storage_account_id = azurerm_storage_account.sanitised_uploads[0].id

  rule {
    name    = "DeleteAfter7Days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}
