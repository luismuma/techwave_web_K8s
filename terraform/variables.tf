################################
# GENERAL
################################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-demo"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

################################
# ADMIN
################################
variable "admin_user_name" {
  description = "IAM user for EKS admin access"
  type        = string
  default     = "eks-admin-user"
}

################################
# NETWORK
################################
variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

################################
# NODE GROUP
################################
variable "node_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

################################
# ACCESS
################################
variable "endpoint_public_access" {
  description = "Expose EKS API publicly"
  type        = bool
  default     = true
}

################################
# TAGS
################################
variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks-demo"
  }
}
