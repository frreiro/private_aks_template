resource "kubernetes_manifest" "blob_storageclass_nfs_standard" {
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name" = "azureblob-nfs-standard-zrs"
    }
    "provisioner" = "blob.csi.azure.com"
    "parameters" = {
      "protocol"            = "nfs"
      "skuName"             = "Standard_ZRS"
      "resourceGroup"       = "${var.resource_group_name}"
      "networkEndpointType" = "privateEndpoint"
    }
    "volumeBindingMode"    = "Immediate"
    "allowVolumeExpansion" = "true"

  }
}

