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
# Secrets Manager: credenciais de cada serviço, lidas pelo External Secrets no cluster

# Chave mestra do auth-service (usada para criar as API keys dos outros serviços)
resource "random_password" "auth_master_key" {
  length  = 32
  special = false
}

# API key do evaluation-service (chama o flag e o targeting, que validam no auth-service)
# Mesmo formato das chaves geradas pelo auth (prefixo tm_key_); o auth só guarda o hash
resource "random_password" "evaluation_api_key" {
  length  = 64
  special = false
}

locals {
  # DATABASE_URL no formato esperado pelos serviços, montada com os dados do RDS
  database_urls = {
    for service, db in module.rds :
    service => "postgres://${db.username}:${db.password}@${db.address}:${db.port}/${db.db_name}?sslmode=require"
  }

  evaluation_api_key = "tm_key_${random_password.evaluation_api_key.result}"

  # Chaves de cada segredo (viram as chaves do Secret no Kubernetes)
  app_secrets = {
    "auth-service" = {
      DB_URL     = local.database_urls["auth-service"]
      MASTER_KEY = random_password.auth_master_key.result
      # SHA-256 em hex, igual ao hashAPIKey do auth; o Job db-init grava na tabela api_keys
      EVALUATION_KEY_HASH = sha256(local.evaluation_api_key)
    }
    "flag-service" = {
      DB_URL = local.database_urls["flag-service"]
    }
    "targeting-service" = {
      DB_URL = local.database_urls["targeting-service"]
    }
    "evaluation-service" = {
      REDIS_URL       = module.elasticache.url
      SERVICE_API_KEY = local.evaluation_api_key
    }
  }
}

module "secrets" {
  source = "../../modules/secrets-manager"
  # for_each pelos nomes fixos: valores derivados de dados sensíveis não podem ser chave de for_each
  for_each = toset(["auth-service", "flag-service", "targeting-service", "evaluation-service"])

  name   = "${var.project}/${each.key}"
  values = local.app_secrets[each.key]
}

# Role do External Secrets (Pod Identity) com leitura só desses segredos
module "external_secrets" {
  source = "../../modules/external-secrets"

  cluster_name = module.eks.cluster_name
  secret_arns  = [for s in module.secrets : s.arn]
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
# Pod Identity: role de cada serviço que chama APIs da AWS (sem access key em Secret)

# evaluation-service: só publica na fila
module "evaluation_identity" {
  source = "../../modules/pod-identity"

  name            = "evaluation-service"
  cluster_name    = module.eks.cluster_name
  namespace       = "evaluation-service"
  service_account = "sa-evaluation-service"
  statements = [
    {
      actions   = ["sqs:SendMessage"]
      resources = [module.sqs.queue_arn]
    },
  ]
}

# analytics-service: consome a fila e grava na tabela
module "analytics_identity" {
  source = "../../modules/pod-identity"

  name            = "analytics-service"
  cluster_name    = module.eks.cluster_name
  namespace       = "analytics-service"
  service_account = "sa-analytics-service"
  statements = [
    {
      actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      resources = [module.sqs.queue_arn]
    },
    {
      actions   = ["dynamodb:PutItem"]
      resources = [module.dynamodb.table_arn]
    },
  ]
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
