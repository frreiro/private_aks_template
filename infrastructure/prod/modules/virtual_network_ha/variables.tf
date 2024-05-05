variable "name" {
  type        = string
  description = "Infrastructure name"
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}

variable "address_space" {
  type        = string
  description = "CIDR range for the Virtual Network"
}

variable "stage" {
  type        = string
  description = "Infrastructure stage"
}

variable "hub_address_space" {
  type = string
}