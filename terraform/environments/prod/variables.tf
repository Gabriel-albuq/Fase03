# variables.tf
# Declaração de variáveis com diferentes tipos


# ============================================================================
# Gerais do projeto
variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefixo dos recursos"
  type        = string
  default     = "fase03-fiap"
}

variable "zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Conjunto de tags únicas"
  type        = set(string)
  default     = ["prod", "terraform"]
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "prod"
}

# ============================================================================
# VPC
variable "vpc_cidr" {
  description = "Bloco CIDR para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (um por zona, na ordem de zones)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (um por zona, na ordem de zones)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
