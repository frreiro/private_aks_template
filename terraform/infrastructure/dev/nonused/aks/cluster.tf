resource "azurerm_kubernetes_cluster" "kubernetes-cluster" {
  name                = "${var.stage}-${lower(var.name)}-cluster"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.stage}-${lower(var.name)}"
  kubernetes_version  = "1.28.5"
  

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 70
    vnet_subnet_id      = var.subnet_id #https://registry.terraform.io/providers/hashicorp/azurerm/3.50.0/docs/resources/kubernetes_cluster
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
    zones               = [1, 2] #VMSIZE Standard_DS2_v2 only works on zone 1 and 2.
  }


  service_principal {
    client_id     = var.serviceprinciple_id
    client_secret = var.serviceprinciple_key
  }

  network_profile {
    network_plugin = "kubenet"
    pod_cidr       = "12.0.0.0/22"
    service_cidr   = "192.168.0.0/24"
    dns_service_ip = "192.168.0.10"
    load_balancer_sku = "standard"
    outbound_type = "userAssignedNATGateway"
    nat_gateway_profile {
      idle_timeout_in_minutes = 10
    }
  }

  tags = {
    Environment = "${var.stage}-${lower(var.name)}-cluster"
  }

  lifecycle {
    ignore_changes = [
      network_profile[0].nat_gateway_profile
    ]
  }
}
