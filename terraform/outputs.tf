output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "admin_user_arn" {
  value = aws_iam_user.eks_admin.arn
}
