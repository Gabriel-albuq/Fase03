# outputs.tf
# Saídas do módulo pod-identity

output "role_arn" {
  description = "ARN da role usada pelo serviço"
  value       = aws_iam_role.main.arn
}
