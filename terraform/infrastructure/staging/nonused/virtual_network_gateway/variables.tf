variable "enable" {
  type = bool
}
variable "virtual_network_name" {
  type = string
}

variable "address_space" {
  type        = string
  description = "CIDR range for the Virtual Network"
}

variable "address_space_gateway" {
  type        = string
  description = "CIDR range for the Virtual Network"
}

variable "stage" {
  type        = string
  description = "Infrastructure stage"
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}