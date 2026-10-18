# outputs.tf
# Saídas do módulo secrets-manager, usadas na policy de IAM do External Secrets

output "name" {
  description = "Nome do segredo (usado no remoteRef/extract do ExternalSecret)"
  value       = aws_secretsmanager_secret.main.name
}

output "arn" {
  description = "ARN do segredo, para policies de IAM"
  value       = aws_secretsmanager_secret.main.arn
}
