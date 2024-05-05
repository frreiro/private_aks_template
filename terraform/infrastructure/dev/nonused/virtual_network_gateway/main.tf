data "azurerm_client_config" "current" {}
resource "azurerm_subnet" "vpn" {
  count = var.enable ? 1 : 0

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 50)]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_public_ip" "vpn_ip" {
  count = var.enable ? 1 : 0

  name                = "${title(lower(var.stage))}VPNP2SIp"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  allocation_method   = "Static"
}


resource "azurerm_virtual_network_gateway" "vpn" {
  count = var.enable ? 1 : 0

  name                = "${title(lower(var.stage))}VPNP2S"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "${title(lower(var.stage))}VNETGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_ip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn[0].id
  }

  vpn_client_configuration {
    address_space = [cidrsubnet(var.address_space_gateway, 8, 0)]

    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
  }

  depends_on = [data.azurerm_client_config.current, azurerm_public_ip.vpn_ip, azurerm_subnet.vpn]

}
