# variables.tf
# Entradas do módulo rds (uma instância PostgreSQL por chamada)

variable "name" {
  description = "Prefixo dos nomes dos recursos (ex: fase03-fiap-auth-service)"
  type        = string
}

variable "vpc_id" {
  description = "VPC onde o security group do banco será criado"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do subnet group (mínimo 2 AZs)"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group com acesso liberado à porta do banco (o do cluster EKS)"
  type        = string
}

variable "db_name" {
  description = "Nome do banco criado na instância"
  type        = string
}

variable "username" {
  description = "Usuário master do banco"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Tamanho do disco, em GB"
  type        = number
  default     = 20
}
