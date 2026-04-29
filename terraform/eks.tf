################################
# DATA: CURRENT AWS ACCOUNT
################################
data "aws_caller_identity" "current" {}

################################
# DATA: EKS CLUSTER (❌ DESACTIVAR TEMPORALMENTE)
################################
# ⛔ ESTO ROMPE EL PLAN SI EL CLUSTER NO EXISTE AÚN
# data "aws_eks_cluster" "this" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "this" {
#   name = var.cluster_name
# }

################################
# EKS CLUSTER
################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids             = aws_subnet.eks[*].id
    endpoint_public_access = var.endpoint_public_access
  }

  ################################
  # AUTH MODE MODERNO
  ################################
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  ################################
  # DRIFT CONTROL
  ################################
  lifecycle {
    ignore_changes = [
      vpc_config,
      version,
      access_config,
      kubernetes_network_config,
      role_arn,
      upgrade_policy
    ]
  }

  tags = var.tags
}

################################
# ACCESS ENTRY (ADMIN)
################################
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.eks_admin_role_arn
  type          = "STANDARD"
}

################################
# ADMIN POLICY
################################
resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.eks_admin_role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

################################
# NODE GROUP
################################
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = aws_subnet.eks[*].id

  version  = var.cluster_version
  ami_type = "AL2_x86_64"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.node_instance_type]

  tags = var.tags

  depends_on = [
    aws_eks_cluster.this
  ]
}
