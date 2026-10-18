# main.tf
# Segredo no AWS Secrets Manager, lido pelo External Secrets e entregue aos pods como Secret do Kubernetes

resource "aws_secretsmanager_secret" "main" {
  name = var.name

  # Sem janela de recuperação: permite terraform destroy + apply com o mesmo nome
  recovery_window_in_days = 0

  tags = {
    Name = var.name
  }
}

# Valores guardados como JSON ({"DB_URL": "...", ...}); cada chave vira uma chave do Secret no Kubernetes
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.values)
}
