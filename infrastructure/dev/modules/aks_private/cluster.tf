
locals {
  resource_group_name_updated = replace(var.resource_group.name, "/_STAGING_|_DEV_/", "_")
}

data "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.centralus.azmk8s.io"
  resource_group_name = local.resource_group_name_updated
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "${title(lower(var.stage))}aksvnetzone"
  resource_group_name   = local.resource_group_name_updated
  private_dns_zone_name = data.azurerm_private_dns_zone.aks.name
  virtual_network_id    = var.virtual_network_id

  depends_on = [data.azurerm_private_dns_zone.aks]
}

resource "azurerm_role_assignment" "dns_role" {
  scope                = data.azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = var.principal_id
}


resource "azurerm_kubernetes_cluster" "kubernetes-cluster" {
  name                       = "${title(lower(var.stage))}${var.name}Cluster"
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  dns_prefix_private_cluster = "${lower(var.stage)}-${lower(var.name)}"
  # dns_prefix = "${lower(var.stage)}-${lower(var.name)}"
  kubernetes_version = "1.28.5"

  private_cluster_enabled = true
  private_dns_zone_id     = data.azurerm_private_dns_zone.aks.id

  default_node_pool {
    name                        = "default"
    # node_count                  = 1
    vm_size                     = "Standard_D2ls_v5"
    type                        = "VirtualMachineScaleSets"
    os_disk_size_gb             = 70
    vnet_subnet_id              = var.subnets[0] #https://registry.terraform.io/providers/hashicorp/azurerm/3.50.0/docs/resources/kubernetes_cluster
    enable_auto_scaling         = true
    max_count                   = 3
    min_count                   = 1
    zones                       = [1, 2, 3]
    temporary_name_for_rotation = "tmpnodepool"

    upgrade_settings {
      max_surge = "10%"
    }

  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }


  network_profile {
    network_plugin    = "kubenet"
    pod_cidr          = "12.0.0.0/16"
    service_cidr      = "192.168.0.0/24"
    dns_service_ip    = "192.168.0.10"
    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"
    nat_gateway_profile {
      idle_timeout_in_minutes = 10
    }
  }

  storage_profile {
    blob_driver_enabled = true
    disk_driver_enabled = true
  }
  tags = {
    Environment = "${lower(var.stage)}-${lower(var.name)}-cluster"
  }

  lifecycle {
    ignore_changes = [
      network_profile[0].nat_gateway_profile
    ]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.aks,
    azurerm_role_assignment.dns_role
  ]
}
