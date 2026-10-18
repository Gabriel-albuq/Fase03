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

# Nome do cluster em um só lugar precisa ser igual nas tags das subnets e no EKS
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
  subnet_ids   = module.networking.private_subnet_ids # Nodes nas subnets privadas que saem do output do networking
  desired_size = 2                                    # 1 t3.medium comporta só 17 pods; ver observacoes.txt
}

# ============================================================================
# RDS: um PostgreSQL por serviço que usa banco (chave = serviço, valor = nome do banco)
module "rds" {
  source = "../../modules/rds"
  for_each = {
    "auth-service"      = "auth_db"
    "flag-service"      = "flags_db"
    "targeting-service" = "targeting_db"
  }

  name                      = "${var.project}-${each.key}"
  db_name                   = each.value
  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.private_subnet_ids
  allowed_security_group_id = module.eks.cluster_security_group_id
}

# ============================================================================
# ElastiCache: Redis usado como cache pelo evaluation-service
module "elasticache" {
  source = "../../modules/elasticache"

  name                      = "${var.project}-redis"
  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.private_subnet_ids
  allowed_security_group_id = module.eks.cluster_security_group_id
}

# ============================================================================
# DynamoDB: tabela de eventos gravada pelo analytics-service
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "ToggleMasterAnalytics"
}

# ============================================================================
# SQS: fila de eventos entre o evaluation-service e o analytics-service
module "sqs" {
  source = "../../modules/sqs"

  name = "${var.project}-analytics-events"
}

# ============================================================================
# ECR: um repositório de imagens por microsserviço (mesmos nomes da Fase 2)
module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
  ]
}
