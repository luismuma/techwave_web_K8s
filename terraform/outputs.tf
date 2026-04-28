output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "admin_role_arn" {
  description = "IAM role used for cluster admin access"
  value = try(aws_iam_role.eks_admin.arn, null)
}
