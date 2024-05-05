resource "azurerm_kubernetes_cluster_node_pool" "node_pool_cluster" {
  name                  = "${var.stage}nodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes-cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  enable_auto_scaling   = true
  max_count             = 1
  min_count             = 1
  os_disk_size_gb       = 50
  zones                 = [1, 2]
  os_type               = "Linux"
  mode                  = "System"
  vnet_subnet_id        = var.subnet_id
  max_pods              = 40

  node_labels = {
    "environment" = "${var.stage}-${lower(var.name)}-node-pool"
  }

  tags = {
    Environment = "${var.stage}-${lower(var.name)}-node-pool"
  }
}
