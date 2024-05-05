variable "cluster_name" {
  type = string
}
variable "stage" {
  type = string
}

variable "config_keyvault_name" {
  type = string
}

variable "client_id" {
  type = string
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}