# main.tf
# Redis (ElastiCache) privado, acessível apenas a partir do cluster EKS

# ============================================================================
# Rede

# Subnets privadas onde o Redis pode ser colocado
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-subnets"
  }
}

# Libera o Redis só para o security group do cluster
resource "aws_security_group" "main" {
  name        = "${var.name}-sg"
  description = "Acesso ao Redis a partir do cluster EKS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis a partir do EKS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

# ============================================================================
# Redis

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = var.name
  description          = "Cache do evaluation-service"

  engine             = "redis"
  engine_version     = var.engine_version
  node_type          = var.node_type
  num_cache_clusters = 1 # Sem replicas
  port               = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.main.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  automatic_failover_enabled = false # Exige réplica; desligado com 1 nó só
  snapshot_retention_limit   = 0
  apply_immediately          = true
}
