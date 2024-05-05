output "host" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.kube_config[0].host
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.kube_config[0].client_certificate
}

output "client_key" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.kube_config[0].client_key
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.kube_config[0].cluster_ca_certificate
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.name
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.kubernetes-cluster.kubelet_identity[0].object_id
}