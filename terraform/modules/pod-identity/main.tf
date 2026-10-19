# main.tf
# Role de IAM de um microsserviço, ligada ao ServiceAccount dele via EKS Pod Identity
# (substitui o AWS_ACCESS_KEY_ID/SECRET em Secret usado na Fase 2)

# ============================================================================
# Role

# Assumida pelo agente do Pod Identity em nome do pod do serviço
resource "aws_iam_role" "main" {
  name = "${var.cluster_name}-${var.name}"

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

# Só as ações e recursos que o serviço usa (passados pelo chamador)
resource "aws_iam_role_policy" "main" {
  name = "${var.name}-access"
  role = aws_iam_role.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for s in var.statements : {
        Action   = s.actions
        Effect   = "Allow"
        Resource = s.resources
      }
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
