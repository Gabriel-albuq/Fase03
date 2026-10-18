# variables.tf
# Entradas do módulo secrets-manager

variable "name" {
  description = "Nome do segredo (ex: fase03-fiap/auth-service)"
  type        = string
}

variable "values" {
  description = "Chaves e valores do segredo (ex: DB_URL, MASTER_KEY)"
  type        = map(string)
  sensitive   = true
}
