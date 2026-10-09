# backend.tf
# Configuração do backend remoto para armazenar o state no S3

terraform {
  backend "s3" {
    bucket       = "fase03-fiap"                  # Substitua pelo nome do seu bucket S3
    key          = "infra/prod/terraform.tfstate" # Caminho do arquivo state
    region       = "us-east-1"                    # Região do bucket
    encrypt      = true                           # Ativar criptografia do state
    use_lockfile = true                           # Lock nativo no S3 (substitui a tabela DynamoDB)
  }
}