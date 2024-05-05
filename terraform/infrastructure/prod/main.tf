resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.resource_group_location

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  application_name = var.application_name
  resource_group = {
    name     = azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
  }
  resource_group_location = azurerm_resource_group.this.location
  resource_group_name     = azurerm_resource_group.this.name
  vnet_address_space      = var.vnet_address_space
  stage                   = var.stage
  zones                   = var.zones
  client_id               = var.client_id
  client_secret           = var.client_secret
  tenant_id               = var.tenant_id
  object_id               = var.object_id
  subscription_id         = var.subscription_id
  database_username       = var.database_username
  database_password       = var.database_password
  vault_name              = "${local.application_name}VaultConfig"
  hub_address_space       = var.hub_address_space
  vnet_name               = "${local.application_name}FW1-VNET"
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "${lower(var.stage)}-user-identity"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
}


module "virtual_network" {
  source            = "./modules/virtual_network_ha"
  name              = local.vnet_name
  stage             = local.stage
  resource_group    = local.resource_group
  zones             = local.zones
  address_space     = local.vnet_address_space
  hub_address_space = local.hub_address_space
}

module "hub_vpn" {
  source               = "./modules/vpn"
  stage                = "HUB"
  resource_group       = local.resource_group
  virtual_network_name = module.virtual_network.hub_vnet_name
  address_space        = local.hub_address_space

  depends_on = [module.virtual_network]
}

# module "vpn1" {
#   source               = "./modules/vpn"
#   stage                = local.stage
#   resource_group       = local.resource_group
#   virtual_network_name = module.virtual_network.virtual_network_name
#   address_space        = local.vnet_address_space

#   depends_on = [module.virtual_network]
# }

module "acr" {
  source         = "./modules/acr"
  name           = local.application_name
  resource_group = local.resource_group
  stage          = local.stage
  depends_on     = [module.virtual_network]
}


module "vault" {
  source                 = "./modules/key_vaults"
  name                   = local.vault_name
  resource_group         = local.resource_group
  stage                  = local.stage
  client_id              = local.client_id
  tenant_id              = local.tenant_id
  object_id              = local.object_id
  virtual_network_id     = module.virtual_network.virtual_network_id
  virtual_network_hub_id = module.virtual_network.hub_vnet_id
  subnet_internal        = module.virtual_network.internal_subnet
  subnets = setunion(
    [
      module.virtual_network.external_subnet,
      module.virtual_network.internal_subnet,
      module.virtual_network.protected_subnet,
      module.hub_vpn.vpn_subnet_id,
    ]
    , module.virtual_network.private_subnets
  )
  principal_id = azurerm_user_assigned_identity.identity.principal_id

  depends_on = [module.acr]
}

module "database" {
  source                 = "./modules/database"
  stage                  = local.stage
  resource_group         = local.resource_group
  database_subnet_id     = module.virtual_network.private_subnet_database_id
  virtual_network_id     = module.virtual_network.virtual_network_id
  virtual_network_hub_id = module.virtual_network.hub_vnet_id

  admin_login    = local.database_username
  admin_password = local.database_password
  depends_on     = [module.vault]

}

module "monitor" {
  source         = "./modules/monitor"
  stage          = local.stage
  resource_group = local.resource_group
  object_id      = var.object_id ## Remove 
  principal_id   = azurerm_user_assigned_identity.identity.principal_id
}

module "aks" {
  source                 = "./modules/aks_private"
  name                   = local.application_name
  stage                  = local.stage
  virtual_network_id     = module.virtual_network.virtual_network_id
  virtual_network_hub_id = module.virtual_network.hub_vnet_id
  resource_group         = local.resource_group

  identity_ids = [azurerm_user_assigned_identity.identity.id]
  principal_id = azurerm_user_assigned_identity.identity.principal_id

  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  subnets = module.virtual_network.private_subnets
  zones   = local.zones

  depends_on = [module.database]
}

resource "azurerm_role_assignment" "aks_and_acr" {
  scope                            = module.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_identity
  skip_service_principal_aad_check = true
}


# module "grafana" {
#   source = "./modules/monitor_grafana"

#   application_name       = local.application_name
#   stage                  = local.stage
#   resource_group         = local.resource_group
#   monitor_workspace_id   = module.monitor.id
#   virtual_network_id     = module.virtual_network.virtual_network_id
#   virtual_network_hub_id = module.virtual_network.hub_vnet_id
#   internal_subnet_id     = module.virtual_network.internal_subnet
#   identity_ids           = [azurerm_user_assigned_identity.identity.id]
#   principal_id           = azurerm_user_assigned_identity.identity.principal_id
# }