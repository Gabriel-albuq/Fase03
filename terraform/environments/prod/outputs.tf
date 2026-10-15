# outputs.tf
# Saídas do ambiente prod, usadas no kubeconfig, nos Secrets/ConfigMaps do Kubernetes e no CI

# ============================================================================
# EKS
output "cluster_name" {
  description = "Nome do cluster EKS (usado no aws eks update-kubeconfig)"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = module.eks.cluster_endpoint
}

# ============================================================================
# RDS: um bloco por serviço (auth-service, flag-service, targeting-service)
output "rds" {
  description = "Hostname, porta, banco e usuário de cada PostgreSQL"
  value = {
    for service, db in module.rds : service => {
      address  = db.address
      port     = db.port
      db_name  = db.db_name
      username = db.username
    }
  }
}

output "rds_passwords" {
  description = "Senha master de cada PostgreSQL (ver com: terraform output -json rds_passwords)"
  value       = { for service, db in module.rds : service => db.password }
  sensitive   = true
}

# ============================================================================
# ElastiCache
output "redis_url" {
  description = "URL do Redis para a variável REDIS_URL do evaluation-service"
  value       = module.elasticache.url
}

# ============================================================================
# DynamoDB e SQS
output "dynamodb_table_name" {
  description = "Nome da tabela de eventos do analytics-service"
  value       = module.dynamodb.table_name
}

output "sqs_queue_url" {
  description = "URL da fila (variável AWS_SQS_URL)"
  value       = module.sqs.queue_url
}

# ============================================================================
# ECR
output "ecr_repository_urls" {
  description = "URL de cada repositório (nome => URL), usada no CI e nos deployments"
  value       = module.ecr.repository_urls
}

output "ecr_registry_id" {
  description = "ID do registry (ID da conta AWS), usado no login do CI"
  value       = module.ecr.registry_id
}
