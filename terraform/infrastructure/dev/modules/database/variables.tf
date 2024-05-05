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
variable "database_subnet_id" {
  type = string
}

variable "admin_login" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

# variable "virtual_network_hub_id" {
#   type = string
# }
