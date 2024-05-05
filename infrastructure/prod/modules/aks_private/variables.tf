variable "stage" {
  type = string
}

variable "name" {
  type = string
}

variable "virtual_network_id" {
  type = string
}
variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "subnets" {
  type = list(string)
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "principal_id" {
  type = string
}

variable "identity_ids" {
  type = list(string)
}

variable "virtual_network_hub_id" {
  type = string
}
# variable "acr_id" {
#   type = string
# }