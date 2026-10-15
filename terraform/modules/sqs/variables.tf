# variables.tf
# Entradas do módulo sqs

variable "name" {
  description = "Nome da fila (ex: fase03-fiap-analytics-events)"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Tempo que a mensagem fica invisível para outros consumidores enquanto é processada"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Tempo que uma mensagem não consumida fica na fila (padrão: 4 dias)"
  type        = number
  default     = 345600
}
