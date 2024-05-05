resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${lower(var.stage)}.databasevnetzone.com"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group.name

  depends_on = [azurerm_private_dns_zone.this]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "${lower(var.stage)}.hub.databasevnetzone.com"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_hub_id
  resource_group_name   = var.resource_group.name

  depends_on = [azurerm_private_dns_zone.this]
}


resource "azurerm_postgresql_flexible_server" "database" {

  name                   = "${lower(var.stage)}-psql-flexible-server"
  resource_group_name    = var.resource_group.name
  location               = var.resource_group.location
  version                = "16"
  delegated_subnet_id    = var.database_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.this.id
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  zone                   = 2
  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = 1
  }

  authentication {
    active_directory_auth_enabled = false
  }

  storage_mb                   = 32768
  storage_tier                 = "P4"
  backup_retention_days        = 10
  geo_redundant_backup_enabled = true


  sku_name = "GP_Standard_D2s_v3"
  # sku_name   = "GP_Standard_D4s_v3"

  lifecycle {
    ignore_changes = [
      administrator_login,
      administrator_password
    ]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}
