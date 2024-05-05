variable "stage" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "serviceprincipal_id" {
  type = string
}

variable "serviceprincipal_key" {
  type = string
}

variable "serviceprincipal_object_id" {
  type = string
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "subnets" {
  type = list(string)
}

variable "acr_id" {
  type = string
}