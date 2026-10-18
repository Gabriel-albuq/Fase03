# outputs.tf
# Saídas do módulo external-secrets

output "role_arn" {
  description = "ARN da role usada pelo External Secrets"
  value       = aws_iam_role.main.arn
}
