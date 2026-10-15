# main.tf
# Repositórios ECR onde o CI publica as imagens dos microsserviços

resource "aws_ecr_repository" "main" {
  for_each = var.repository_names

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = true # Permite o terraform destroy mesmo com imagens dentro

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}
