# variables.tf
# Entradas do módulo elasticache (Redis usado como cache pelo evaluation-service)

variable "name" {
  description = "Prefixo dos nomes dos recursos (ex: fase03-fiap-redis)"
  type        = string
}

variable "vpc_id" {
  description = "VPC onde o security group do Redis será criado"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do subnet group"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group com acesso liberado à porta do Redis (o do cluster EKS)"
  type        = string
}

variable "engine_version" {
  description = "Versão do Redis"
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Tipo de instância dos nós do Redis"
  type        = string
  default     = "cache.t3.micro"
}
