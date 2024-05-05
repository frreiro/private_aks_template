resource "azurerm_container_registry" "acr" {
  name                = "${title(lower(var.stage))}${var.name}Repository"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = "Basic"
}

#Mudar para premium em produção para habilitar acesso privado