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

output "app_url" {
  description = "Public URL of the application LoadBalancer"
  value = try(
    kubernetes_service_v1.app.status[0].load_balancer[0].ingress[0].hostname,
    "pending-loadbalancer"
  )
}
