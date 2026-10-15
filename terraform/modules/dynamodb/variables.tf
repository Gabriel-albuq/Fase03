# variables.tf
# Entradas do módulo dynamodb

variable "table_name" {
  description = "Nome da tabela (precisa bater com AWS_DYNAMODB_TABLE do analytics-service)"
  type        = string
}

variable "hash_key" {
  description = "Partition key da tabela (tipo String)"
  type        = string
  default     = "event_id"
}
