

resource "azurerm_private_dns_zone" "grafana" {
  name                = "privatelink.grafana.azure.com"
  resource_group_name = var.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "grafana" {
  name                  = "privatelink.grafana.net"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.grafana.name
  virtual_network_id    = var.virtual_network_id

  depends_on = [azurerm_private_dns_zone.grafana]
}

resource "azurerm_dashboard_grafana" "dashboards" {
  name                = "${lower(var.stage)}-${lower(var.application_name)}-grafana"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = false
  sku                               = "Standard"
  grafana_major_version             = "10"
  zone_redundancy_enabled           = false


  azure_monitor_workspace_integrations {
    resource_id = var.monitor_workspace_id
  }


  tags = {
    Environment = "${lower(var.stage)}"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.grafana]
}

resource "azurerm_private_endpoint" "grafana" {
  name                = format("pe-%s", "${lower(var.stage)}-grafana")
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = var.internal_subnet_id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.grafana.id]
  }

  private_service_connection {
    name                           = format("pse-%s", "${lower(var.stage)}-grafana")
    private_connection_resource_id = azurerm_dashboard_grafana.dashboards.id
    is_manual_connection           = false
    subresource_names              = ["grafana"]
  }
}


## Resource grafana_managed_private_endpoint is not support by azurerm terraform provider yet, was necessary use the azapi to create it
##  https://github.com/hashicorp/terraform-provider-azurerm/issues/23950

resource "azapi_resource" "grafana_managed_private_endpoint_connection" {
  type      = "Microsoft.Dashboard/grafana/managedPrivateEndpoints@2022-10-01-preview"
  name      = "${lower(var.stage)}-managed-pe"
  location  = var.resource_group.location
  parent_id = azurerm_dashboard_grafana.dashboards.id
  body = jsonencode({
    properties = {
      groupIds = [
        "prometheusMetrics"
      ]
      privateLinkResourceId     = var.monitor_workspace_id
      privateLinkResourceRegion = var.resource_group.location
      requestMessage            = "Created by Terraform"
    }
  })
}

# the actual azurerm_monitor_workspace resource doesn't yet export the private endpoint connections information
# so we use the azapi provider to get that (once they've been created, otherwise things fail)
data "azapi_resource" "azurerm_monitor_workspace" {
  type                   = "Microsoft.Monitor/accounts@2023-04-03"
  resource_id            = var.monitor_workspace_id
  response_export_values = ["properties.privateEndpointConnections"]
  depends_on             = [azapi_resource.grafana_managed_private_endpoint_connection]
}

locals {
  private_endpoint_connection_name = element([
    for connection in jsondecode(data.azapi_resource.azurerm_monitor_workspace.output).properties.privateEndpointConnections
    : connection.name
    if endswith(connection.properties.privateEndpoint.id, "${lower(var.stage)}-managed-pe")
  ], 0)
}

# Approve the managed private endpoints - this is rather hacky, but remarkably it works since the azurerm
# provider doesn't have the ability to do this natively yet 
resource "azapi_update_resource" "grafana_managed_private_endpoint_connection_approval" {
  type      = "Microsoft.Monitor/accounts/privateEndpointConnections@2023-04-03"
  name      = local.private_endpoint_connection_name
  parent_id = var.monitor_workspace_id

  body = jsonencode({
    properties = {
      privateLinkServiceConnectionState = {
        actionsRequired = "None"
        description     = "Approved via Terraform"
        status          = "Approved"
      }
    }
  })
  depends_on = [azapi_resource.grafana_managed_private_endpoint_connection]
}

