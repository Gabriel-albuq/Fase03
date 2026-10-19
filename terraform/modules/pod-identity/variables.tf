# variables.tf
# Entradas do módulo pod-identity

variable "name" {
  description = "Nome do serviço (usado no nome da role e da policy)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "namespace" {
  description = "Namespace do serviço no Kubernetes"
  type        = string
}

variable "service_account" {
  description = "ServiceAccount usado pelo deployment do serviço"
  type        = string
}

variable "statements" {
  description = "Permissões da role: ações e ARNs de cada statement"
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
}
