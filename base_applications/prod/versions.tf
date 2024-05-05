terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.96.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "TERRAFORM_STATE_RG"
    storage_account_name = "terraformstateresource"
    container_name       = "tfstate-base-applications"
    key                  = "terraform.tfstate"
  }
}
