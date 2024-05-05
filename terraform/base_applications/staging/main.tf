data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


locals {
  stage                = var.stage
  config_keyvault_name = var.vault_config_name
  client_id            = var.client_id
  resource_group = {
    name     = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
  }
}

module "storage_class" {
  source              = "./modules/storage_class"
  resource_group_name = local.resource_group.name
}

module "argocd" {
  source = "./modules/argocd"
}
module "external_secrets" {
  source            = "./modules/external_secrets"
  client_id         = var.client_id
  client_secret     = var.client_secret
  tenant_id         = var.tenant_id
  vault_config_name = local.config_keyvault_name
}

module "prometheus" {
  source               = "./modules/kube_prometheus"
  cluster_name         = var.cluster_name
  stage                = local.stage
  config_keyvault_name = local.config_keyvault_name
  resource_group       = local.resource_group
  client_id            = local.client_id

  depends_on = [module.external_secrets]
}

module "ingress_nginx" {
  source = "./modules/ingress_nginx"
  stage  = local.stage

  depends_on = [module.prometheus]
}



module "cert_manager" {
  source = "./modules/cert_manager"
  stage  = local.stage

  depends_on = [module.ingress_nginx]
}


