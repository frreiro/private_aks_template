data "azurerm_client_config" "current" {}
resource "azurerm_subnet" "vpn" {
  name                 = "VPNP2SSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 70)]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_public_ip" "vpn" {
  name                = "${title(lower(var.stage))}VPNP2S-Ip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vpn" {
  name                = "${lower(var.stage)}-vpnp2s-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "vpnp2sconfiguration"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    subnet_id                     = azurerm_subnet.vpn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "vpn" {
  name                = "VPNP2S-NSG"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  tags = {
    environment = "VPN Security group"
  }
}

resource "azurerm_network_security_rule" "allow_admin" {
  name                        = "Admin_TCP"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "943"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.vpn.name
}

resource "azurerm_network_security_rule" "tcp_connection" {
  name                        = "TCP_Connection"
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "443"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.vpn.name
}

resource "azurerm_network_security_rule" "udp_connection" {
  name                        = "UDP_Connection"
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "1194"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.vpn.name
}


resource "azurerm_network_security_rule" "cluster_port" {
  name                        = "Cluster_Port"
  priority                    = 1040
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "945"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.vpn.name
}


resource "azurerm_network_security_rule" "ssh" {
  name                        = "default-allow-ssh"
  priority                    = 1050
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.vpn.name
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.vpn.id
  network_security_group_id = azurerm_network_security_group.vpn.id

  depends_on = [azurerm_network_security_group.vpn, azurerm_network_interface.vpn]
}

resource "azurerm_linux_virtual_machine" "vpn" {
  name                = "OPENVPN-P2S-VM"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  zone                = 2
  network_interface_ids = [
    azurerm_network_interface.vpn.id,
  ]

  plan {
    name      = "openvpnas"
    product   = "openvpnas"
    publisher = "openvpn"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/openvpn-p2s.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "openvpn"
    offer     = "openvpnas"
    sku       = "openvpnas"
    version   = "2.11.03"
  }

  depends_on = [azurerm_network_interface_security_group_association.this]
}