output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "admin_role_arn" {
  value = aws_iam_role.eks_admin.arn
}
