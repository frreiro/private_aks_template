resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "${lower(var.stage)}-log-analytics-workspace"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# resource "azurerm_monitor_workspace" "monitor" {
#   name                          = "${lower(var.stage)}-monitor-workspace"
#   location                      = var.resource_group.location
#   resource_group_name           = var.resource_group.name
#   public_network_access_enabled = false
# }

# #Remove
# resource "azurerm_role_assignment" "publish_metrics_service_principal" {
#   scope                = azurerm_monitor_workspace.monitor.default_data_collection_rule_id
#   role_definition_name = "Monitoring Metrics Publisher"
#   principal_id         = var.object_id
# }

# resource "azurerm_role_assignment" "publish_metrics" {
#   scope                = azurerm_monitor_workspace.monitor.default_data_collection_rule_id
#   role_definition_name = "Monitoring Metrics Publisher"
#   principal_id         = var.principal_id
# }
