# variables.tf
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-demo"
}

variable "admin_user_name" {
  type    = string
  default = "eks-admin-user"
}
