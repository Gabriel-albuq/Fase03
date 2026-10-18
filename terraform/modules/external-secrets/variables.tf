# variables.tf
# Entradas do módulo external-secrets

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "secret_arns" {
  description = "ARNs dos segredos que o External Secrets pode ler"
  type        = list(string)
}

variable "namespace" {
  description = "Namespace onde o External Secrets é instalado (helm install -n)"
  type        = string
  default     = "external-secrets"
}

variable "service_account" {
  description = "ServiceAccount do controller (nome padrão do chart = nome do release)"
  type        = string
  default     = "external-secrets"
}
