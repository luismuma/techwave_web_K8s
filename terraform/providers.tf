terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

################################
# AWS PROVIDER
################################
provider "aws" {
  region = var.region
}

################################
# DATA: EKS CLUSTER (para evitar ciclos)
################################
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

################################
# DATA: EKS AUTH TOKEN
################################
data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

################################
# KUBERNETES PROVIDER (SIN CICLO)
################################
provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.this.token
}
