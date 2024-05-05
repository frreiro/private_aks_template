variable "name" {
  type        = string
  description = "Infrastructure name"
}
variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}
variable "stage" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "subnet_internal" {
  type = string
}
variable "object_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

# variable "virtual_network_hub_id" {
#   type = string
# }

variable "principal_id" {
  type = string
}
