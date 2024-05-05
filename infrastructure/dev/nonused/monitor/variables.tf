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

variable "object_id" {
  type = string
}

variable "principal_id" {
  type = string
}