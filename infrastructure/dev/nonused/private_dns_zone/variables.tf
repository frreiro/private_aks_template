variable "stage" {
  type        = string
  description = "Infrastructure stage"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "resource_group_location" {
  type        = string
  description = "Region of this infreastructure"
  default     = "East US 2"
}

variable "virtual_network_id" {
  type = string
}

