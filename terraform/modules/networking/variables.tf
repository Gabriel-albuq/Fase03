# variables.tf
# Entradas do módulo networking

variable "project" {
  description = "Prefixo dos nomes dos recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "AZs onde as subnets serão criadas"
  type        = list(string)
}

variable "cluster_name" {
  description = "Nome do cluster EKS, usado nas tags das subnets"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas, um por AZ (mesma ordem de azs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas, um por AZ (mesma ordem de azs)"
  type        = list(string)
}
