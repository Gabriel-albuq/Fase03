# main.tf
# Tabela DynamoDB onde o analytics-service grava os eventos de avaliação

resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  # Só a chave é declarada: os demais campos do item não precisam de schema
  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = {
    Name = var.table_name
  }
}
