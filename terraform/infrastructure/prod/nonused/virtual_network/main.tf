
# Create virtual network
resource "azurerm_virtual_network" "this" {
  name                = "${var.stage}-${lower(var.name)}-vnet"
  address_space       = [var.address_space]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create Public Subnet
resource "azurerm_subnet" "public" {
  name                 = "${var.stage}-${lower(var.name)}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 0)]
}


# Create Private Subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.stage}-${lower(var.name)}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 1)]
  # address_prefixes     = [cidrsubnet(var.address_space, 2, 1)]
}


# Create NAT Public IP
resource "azurerm_public_ip" "nat_ip" {
  name                = "${var.stage}-${var.name}-nat-public-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

#Create NAT Gateway
resource "azurerm_nat_gateway" "this" {
  name                    = "${var.stage}-${var.name}-nat"
  location                = var.resource_group_location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = [1]
}

# NAT - Public IP Association
resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat_ip.id
}

# NAT - Subnets association
resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}




# resource "azurerm_subnet" "bastion_subnet" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.this.name
#   address_prefixes     = ["10.10.64.0/24"]
# }

# resource "azurerm_public_ip" "public_ip" {
#   name                = "${var.stage}-${lower(var.name)}-public-ip"
#   resource_group_name  = var.resource_group_name
#   location            = var.resource_group_location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_bastion_host" "bastion" {
#   name                = "${var.stage}-${lower(var.name)}-bastion"
#   resource_group_name  = var.resource_group_name
#   location            = var.resource_group_location

#   ip_configuration {
#     name                 = "bastion-configuration"
#     subnet_id            = azurerm_subnet.bastion_subnet.id
#     public_ip_address_id = azurerm_public_ip.public_ip.id
#   }
# }


