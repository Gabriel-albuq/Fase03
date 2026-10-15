# outputs.tf
# Saídas do módulo sqs, usadas nos ConfigMaps do evaluation-service e do analytics-service

output "queue_url" {
  description = "URL da fila (variável AWS_SQS_URL)"
  value       = aws_sqs_queue.main.url
}

output "queue_arn" {
  description = "ARN da fila, para policies de IAM"
  value       = aws_sqs_queue.main.arn
}
