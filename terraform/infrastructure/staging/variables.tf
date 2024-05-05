variable "application_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}


variable "stage" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "vnet_address_space" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "object_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_username" {
  type = string
}

