################################
# GENERAL AWS / CLUSTER
################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-techwave-web"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

################################
# 🔥 NUEVO — IAM ROLES EXISTENTES
################################

variable "eks_cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "IAM role ARN for node group"
  type        = string
}

variable "eks_admin_role_arn" {
  description = "IAM role ARN for EKS admin access"
  type        = string
}

################################
# ADMIN ACCESS
################################

variable "admin_user_name" {
  description = "IAM user for EKS admin access"
  type        = string
  default     = "eks-admin-user"
}

################################
# NETWORKING
################################

variable "endpoint_public_access" {
  description = "Expose EKS API publicly"
  type        = bool
  default     = true
}

################################
# NODE GROUP
################################

variable "node_instance_type" {
  description = "EC2 instance type for nodes"
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
# TAGS
################################

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks-techwave-web"
  }
}

################################
# KUBERNETES APP (TECHWAVE)
################################

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "techwave-web-aws"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "techwave-web-aws"
}

variable "image" {
  description = "Docker image"
  type        = string
  default     = "lumuma2025/techwave_web_k8s"
}

variable "container_port" {
  description = "Internal container port"
  type        = number
  default     = 8383
}

variable "service_port" {
  description = "External service port"
  type        = number
  default     = 8083
}

variable "replicas" {
  description = "Number of pods"
  type        = number
  default     = 1
}
