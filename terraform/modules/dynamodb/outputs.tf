# outputs.tf
# Saídas do módulo dynamodb, usadas no ConfigMap do analytics-service

output "table_name" {
  description = "Nome da tabela"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN da tabela, para policies de IAM"
  value       = aws_dynamodb_table.main.arn
}
