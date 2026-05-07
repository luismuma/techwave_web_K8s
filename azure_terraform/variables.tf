variable "location" {
  default = "West Europe"
}

variable "docker_username" {
  type      = string
  sensitive = true
}

variable "docker_password" {
  type      = string
  sensitive = true
}
