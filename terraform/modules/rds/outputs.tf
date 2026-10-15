# outputs.tf
# Saídas do módulo rds, usadas para montar a DATABASE_URL dos Secrets do Kubernetes

output "address" {
  description = "Hostname da instância"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Porta do PostgreSQL"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Nome do banco"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Usuário master"
  value       = aws_db_instance.main.username
}

output "password" {
  description = "Senha do usuário master"
  value       = random_password.main.result
  sensitive   = true
}
