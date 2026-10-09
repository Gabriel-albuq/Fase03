# main.tf
# Cluster EKS, node group e as roles de IAM de cada um

# ============================================================================
# IAM do cluster

# Role assumida pelo serviço EKS para gerenciar o control plane
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

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
            Service = "eks.amazonaws.com"
          }
        },
      ]
    })
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ============================================================================
# IAM dos nodes

# Role assumida pelas instâncias EC2 do node group
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

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
            Service = "ec2.amazonaws.com"
          }
        },
      ]
    })
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",          # Node se registra no cluster
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",               # Pods recebem IP da VPC
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # Pull de imagens do ECR
  ])

  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# ============================================================================
# Cluster

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true # kubectl local e GitHub Actions
    endpoint_private_access = true # Nodes falam com a API por dentro da VPC
  }

  # Quem roda o Terraform vira admin do cluster (sem isso o kubectl retorna Unauthorized)
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # A policy precisa estar anexada antes do cluster ser criado (e removida depois dele)
  depends_on = [aws_iam_role_policy_attachment.cluster]
}

# ============================================================================
# Node group

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  disk_size       = var.disk_size

  scaling_config {
    min_size     = var.min_size
    desired_size = var.desired_size
    max_size     = var.max_size
  }

  depends_on = [aws_iam_role_policy_attachment.node]
}
