variable "name" {
  type        = string
  description = "Infrastructure name"
}


variable "stage" {
  type = string
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Region of this infrastructure"
}