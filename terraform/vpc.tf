################################
# VPC
################################
resource "aws_vpc" "eks" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

################################
# INTERNET GATEWAY
################################
resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
}

################################
# SUBNETS PÚBLICAS
################################
resource "aws_subnet" "eks" {
  count                   = 2
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

################################
# ROUTE TABLE PÚBLICA
################################
resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}

################################
# ASOCIAR ROUTES A SUBNETS
################################
resource "aws_route_table_association" "eks_public" {
  count          = length(aws_subnet.eks)
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.eks_public.id
}

################################
# AZs
################################
data "aws_availability_zones" "available" {}
