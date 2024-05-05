
# output "id" {
#   value = azurerm_monitor_workspace.monitor.id
# }
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.monitor.id
}


# output "monitor" {
#   value = azurerm_monitor_workspace.monitor.query_endpoint
# }