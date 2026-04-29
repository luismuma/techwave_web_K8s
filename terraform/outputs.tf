################################
# EKS OUTPUTS (FASE 1)
################################

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "admin_role_arn" {
  value = var.eks_admin_role_arn
}
