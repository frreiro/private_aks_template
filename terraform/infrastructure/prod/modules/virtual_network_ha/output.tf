output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

output "external_subnet" {
  value = azurerm_subnet.external.id
}


output "internal_subnet" {
  value = azurerm_subnet.internal.id
}


output "protected_subnet" {
  value = azurerm_subnet.protected.id
}

output "private_subnets" {
  value = values(azurerm_subnet.private)[*].id
}

output "private_subnet_database_id" {
  value = azurerm_subnet.private_database.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}
