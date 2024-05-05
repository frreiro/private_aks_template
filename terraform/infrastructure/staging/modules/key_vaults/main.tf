locals {
  resource_group_name_updated = replace(var.resource_group.name, "/_STAGING_|_DEV_/", "_")
}

data "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = local.resource_group_name_updated
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${lower(var.stage)}keyvaultvnetzone.com"
  private_dns_zone_name = data.azurerm_private_dns_zone.kv.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = local.resource_group_name_updated

  depends_on = [data.azurerm_private_dns_zone.kv]
}


resource "azurerm_role_assignment" "dns_role" {
  scope                = data.azurerm_private_dns_zone.kv.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = var.principal_id
}

resource "azurerm_key_vault" "application_vault" {
  name                       = var.name
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 40
  # public_network_access_enabled = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = toset(compact(var.subnets))
  }

  lifecycle {
    ignore_changes = [network_acls[0].ip_rules]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}



resource "azurerm_private_endpoint" "pe_kv" {
  name                = format("pe-%s", lower(var.name))
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = var.subnet_internal

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.kv.id]
  }

  private_service_connection {
    name                           = format("pse-2%s", lower(var.name))
    private_connection_resource_id = azurerm_key_vault.application_vault.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

}

resource "azurerm_key_vault_access_policy" "role_access" {
  key_vault_id = azurerm_key_vault.application_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "Get",
    "GetIssuers",
    "ListIssuers",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
  ]


  depends_on = [azurerm_key_vault.application_vault]
}
resource "azurerm_key_vault_access_policy" "app_access" {
  key_vault_id = azurerm_key_vault.application_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "Get",
    "GetIssuers",
    "ListIssuers",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
  ]


  depends_on = [azurerm_key_vault.application_vault]
}

data "azuread_users" "users" {
  user_principal_names = ["airiam_aks1@nisimke.onmicrosoft.com", "airiam_aks2@nisimke.onmicrosoft.com"]
}

resource "azurerm_key_vault_access_policy" "current_user" {
  for_each = toset(data.azuread_users.users.object_ids)

  key_vault_id = azurerm_key_vault.application_vault.id
  tenant_id    = var.tenant_id
  object_id    = each.value

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "Get",
    "GetIssuers",
    "ListIssuers",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
  ]

  depends_on = [data.azuread_users.users]
}