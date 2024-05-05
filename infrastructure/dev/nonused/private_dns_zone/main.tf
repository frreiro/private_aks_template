resource "azurerm_private_dns_zone" "this" {
  name                = "${var.stage}.syntervision.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "prodvnetzone.com"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
}