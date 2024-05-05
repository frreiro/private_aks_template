# Create a nodepool to each zone, allocated in diff subnets
resource "azurerm_kubernetes_cluster_node_pool" "node_pool_cluster" {
  for_each = toset(var.zones)
  name     = "${var.stage}poolaz${each.value}"

  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes-cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  enable_auto_scaling   = true
  max_count             = 1
  min_count             = 1
  os_disk_size_gb       = 50
  zones                 = [tonumber(each.value)]
  os_type               = "Linux"
  mode                  = "System"
  vnet_subnet_id        = var.subnets[index(var.zones, each.value)]
  max_pods              = 40

  node_labels = {
    "environment" = "${var.stage}-${lower(var.name)}-node-pool-az-${each.value}"
  }

  tags = {
    Environment = "${var.stage}-${lower(var.name)}-node-pool-az-${each.value}"
  }
}