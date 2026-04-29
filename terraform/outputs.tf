################################
# EKS OUTPUTS
################################

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "admin_role_arn" {
  value = aws_iam_role.eks_admin.arn
}

################################
# ❌ KUBERNETES OUTPUT (DESACTIVADO FASE 1)
################################

# output "app_url" {
#   value = kubernetes_service_v1.app.status[0].load_balancer[0].ingress[0].hostname
# }
