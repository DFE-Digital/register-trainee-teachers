data "azurerm_subnet" "aks_network" {
  name                 = "aks-snet"
  virtual_network_name = "s189d01-tsc-cluster3-vnet"
  resource_group_name  = "s189d01-tsc-dv-rg"
}

resource "azurerm_storage_account" "tempdata" {
  count                           = 1
  name                            = var.tempdata_storage_account_name
  resource_group_name             = var.backend_resource_group_name
  location                        = var.region_name
  account_replication_type        = var.storage_account_replication_type
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [data.azurerm_subnet.aks_network.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [data.azurerm_resource_group.group]

}
