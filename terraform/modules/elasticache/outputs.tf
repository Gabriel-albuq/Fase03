# outputs.tf
# Saídas do módulo elasticache, usadas no ConfigMap do evaluation-service

output "address" {
  description = "Hostname do nó primário do Redis"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "port" {
  description = "Porta do Redis"
  value       = aws_elasticache_replication_group.main.port
}

output "url" {
  description = "URL no formato esperado pela variável REDIS_URL (rediss:// = com TLS)"
  value       = "rediss://${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
}
