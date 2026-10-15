# outputs.tf
# Saídas do módulo ecr, usadas no push do CI e no image dos deployments

output "repository_urls" {
  description = "URL de cada repositório (nome => URL)"
  value       = { for name, repo in aws_ecr_repository.main : name => repo.repository_url }
}

output "registry_id" {
  description = "ID do registry (o ID da conta AWS), usado no login do CI"
  value       = values(aws_ecr_repository.main)[0].registry_id
}
