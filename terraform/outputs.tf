################################
# EKS OUTPUTS (FASE 1 ESTABLE)
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

output "node_role_arn" {
  value = var.eks_node_role_arn
}

output "cluster_role_arn" {
  value = var.eks_cluster_role_arn
}
