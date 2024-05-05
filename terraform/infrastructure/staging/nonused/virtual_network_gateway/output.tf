output "vpn_subnet_id" {
  value = var.enable ? azurerm_subnet.vpn[0].id : null
}