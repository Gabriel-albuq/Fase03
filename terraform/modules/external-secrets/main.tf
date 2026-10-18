# main.tf
# Role de IAM do External Secrets Operator, ligada ao ServiceAccount dele via EKS Pod Identity

# ============================================================================
# Role

# Assumida pelo agente do Pod Identity em nome do pod do External Secrets
resource "aws_iam_role" "main" {
  name = "${var.cluster_name}-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

# Só leitura, e só dos segredos do projeto
resource "aws_iam_role_policy" "main" {
  name = "read-secrets"
  role = aws_iam_role.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.secret_arns
      },
    ]
  })
}

# ============================================================================
# Pod Identity

# Pods que usam este ServiceAccount recebem credenciais temporárias da role acima
resource "aws_eks_pod_identity_association" "main" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.main.arn
}
