################################
# IAM USER – ADMIN
################################
resource "aws_iam_user" "eks_admin" {
  name = var.admin_user_name
  tags = var.tags
}

################################
# IAM ROLE – CLUSTER
################################
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

################################
# EKS CLUSTER
################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids             = aws_subnet.eks[*].id
    endpoint_public_access  = var.endpoint_public_access
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

################################
# WAIT FOR CLUSTER
################################
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [aws_eks_cluster.this]
  create_duration = "30s"
}

################################
# DATA SOURCES
################################
data "aws_eks_cluster" "this" {
  name       = aws_eks_cluster.this.name
  depends_on = [time_sleep.wait_for_cluster]
}

data "aws_eks_cluster_auth" "this" {
  name       = aws_eks_cluster.this.name
  depends_on = [time_sleep.wait_for_cluster]
}

################################
# KUBERNETES PROVIDER
################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

################################
# IAM ROLE – NODES
################################
resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_nodes_worker" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

################################
# NODE GROUP
################################
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids = aws_subnet.eks[*].id   # ✅ FIX: conexión directa a VPC

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.node_instance_type]

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_cni,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
    time_sleep.wait_for_cluster
  ]
}

################################
# AWS AUTH CONFIGMAP
################################
resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [aws_eks_node_group.this]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([{
      rolearn  = aws_iam_role.eks_nodes.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }])

    mapUsers = yamlencode([{
      userarn  = aws_iam_user.eks_admin.arn
      username = "eks-admin"
      groups   = ["system:masters"]
    }])
  }
}
