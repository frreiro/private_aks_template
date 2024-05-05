locals {
  resource_group_name_updated = replace(var.resource_group.name, "/_STAGING_|_DEV_/", "_")
}

data "azurerm_private_dns_zone" "dns_zone_created" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = local.resource_group_name_updated
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${lower(var.stage)}databasevnetzone.com"
  private_dns_zone_name = data.azurerm_private_dns_zone.dns_zone_created.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = local.resource_group_name_updated

  depends_on = [data.azurerm_private_dns_zone.dns_zone_created]
}

resource "azurerm_postgresql_flexible_server" "database" {
  name                   = "${lower(var.stage)}-psql-flexible-server"
  resource_group_name    = var.resource_group.name
  location               = var.resource_group.location
  version                = "16"
  delegated_subnet_id    = var.database_subnet_id
  private_dns_zone_id    = data.azurerm_private_dns_zone.dns_zone_created.id
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  zone                   = 2

  authentication {
    active_directory_auth_enabled = false
  }

  storage_mb                   = 32768
  storage_tier                 = "P4"
  backup_retention_days        = 10
  geo_redundant_backup_enabled = false


  sku_name = "B_Standard_B1ms"
  # sku_name   = "GP_Standard_D4s_v3"

  lifecycle {
    ignore_changes = [
      administrator_login,
      administrator_password
    ]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}

