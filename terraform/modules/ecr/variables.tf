# variables.tf
# Entradas do módulo ecr

variable "repository_names" {
  description = "Nomes dos repositórios, um por microsserviço"
  type        = set(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE permite sobrescrever uma tag já enviada; IMMUTABLE bloqueia"
  type        = string
  default     = "MUTABLE"
}
