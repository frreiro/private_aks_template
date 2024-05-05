variable "application_name" {
  type = string
}
variable "stage" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "virtual_network_hub_id" {
  type = string
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}

variable "internal_subnet_id" {
  type = string
}

variable "monitor_workspace_id" {
  type = string
}

variable "principal_id" {
  type = string
}

variable "identity_ids" {
  type = list(string)
}