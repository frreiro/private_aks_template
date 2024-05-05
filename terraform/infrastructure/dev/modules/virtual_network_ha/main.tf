locals {
  resource_group_hub = replace(var.resource_group.name, "/_STAGING_|_DEV_/", "_")
}

# Create virtual network
resource "azurerm_virtual_network" "this" {
  name                = "${var.stage}-${var.name}"
  address_space       = [var.address_space]
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  lifecycle {
    prevent_destroy = true
  }
}

## Hub - Spot Topology - Hub created in prod
## https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke?tabs=cli
data "azurerm_virtual_network" "hub" {
  name                = "HUB-${var.name}"
  resource_group_name = local.resource_group_hub
}

data "azurerm_subnet" "vpn" {
  name                = data.azurerm_virtual_network.hub.subnets[0]
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name = local.resource_group_hub
}

resource "azurerm_virtual_network_peering" "first_to_second" {
  name                      = "peer-${lower(var.stage)}-to-hub"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "second_to_first" {
  name                      = "peer-hub-to-${lower(var.stage)}"
  resource_group_name       = local.resource_group_hub
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

resource "azurerm_subnet" "external" {
  name                 = "ExternalSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 10)]
  service_endpoints    = ["Microsoft.KeyVault"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "InternalSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 20)]
  service_endpoints    = ["Microsoft.KeyVault"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "protected" {
  name                 = "ProtectedSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 30)]
  service_endpoints    = ["Microsoft.KeyVault"]

  lifecycle {
    prevent_destroy = true
  }
}



resource "azurerm_subnet" "private_database" {
  name                 = "${title(lower(var.stage))}PrivateSubnetDatabase"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 40)]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "subnet_postgres"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


resource "azurerm_subnet" "private" {
  for_each = toset(var.zones)
  name     = "${title(lower(var.stage))}PrivateSubnetAz${each.value}"

  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, tonumber(each.value * 10) + 100)]
  service_endpoints    = ["Microsoft.KeyVault"]

}




# Create NAT Public IP
resource "azurerm_public_ip" "nat_ip" {
  for_each            = toset(var.zones)
  name                = "${title(lower(var.stage))}NatPublicIpAz${each.value}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [tonumber(each.value)]
}


#Create NAT Gateway
resource "azurerm_nat_gateway" "this" {
  for_each                = toset(var.zones)
  name                    = "${title(lower(var.stage))}NatAz${each.value}"
  location                = var.resource_group.location
  resource_group_name     = var.resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = [tonumber(each.value)]
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  for_each = azurerm_nat_gateway.this

  nat_gateway_id       = each.value.id
  public_ip_address_id = azurerm_public_ip.nat_ip[each.key].id
}

# NAT - Subnets association
resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = azurerm_nat_gateway.this

  nat_gateway_id = each.value.id
  subnet_id      = azurerm_subnet.private[each.key].id
}




