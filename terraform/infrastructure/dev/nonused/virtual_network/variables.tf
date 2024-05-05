variable "name" {
  type        = string
  description = "Infrastructure name"
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

variable "address_space" {
  type        = string
  description = "CIDR range for the Virtual Network"
  default     = "10.10.0.0/16"
}

variable "stage" {
  type        = string
  description = "Infrastructure stage"
}