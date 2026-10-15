# main.tf
# Fila de eventos: o evaluation-service publica e o analytics-service consome

resource "aws_sqs_queue" "main" {
  name                       = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = 20
  sqs_managed_sse_enabled    = true

  tags = {
    Name = var.name
  }
}
