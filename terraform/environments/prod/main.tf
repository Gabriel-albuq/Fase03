# main.tf
# Provider AWS e chamada dos módulos da infraestrutura


provider "aws" {
  region = var.aws_region

  # Tags aplicadas automaticamente em todos os recursos
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
    }
  }
}

# Nome do cluster em um só lugar: precisa ser igual nas tags das subnets e no EKS
locals {
  cluster_name = "${var.project}-eks"
}

# ============================================================================
# Networking: VPC, subnets públicas/privadas, IGW, NAT e rotas
module "networking" {
  source = "../../modules/networking"

  project      = var.project
  vpc_cidr     = var.vpc_cidr
  azs          = var.zones
  cluster_name = local.cluster_name

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ============================================================================
# EKS: cluster, node group e roles de IAM
module "eks" {
  source = "../../modules/eks"

  cluster_name = local.cluster_name
  subnet_ids   = module.networking.private_subnet_ids # Nodes nas subnets privadas
}
