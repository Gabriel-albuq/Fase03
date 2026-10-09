# variables.tf
# Entradas do módulo eks

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets do cluster e dos nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "Tipos de instância EC2 dos nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "disk_size" {
  description = "Tamanho do disco de cada node, em GB"
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Quantidade mínima de nodes"
  type        = number
  default     = 1
}

variable "desired_size" {
  description = "Quantidade desejada de nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Quantidade máxima de nodes"
  type        = number
  default     = 5
}
