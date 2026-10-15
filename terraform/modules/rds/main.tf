# main.tf
# Instância RDS PostgreSQL privada, acessível apenas a partir do cluster EKS

# ============================================================================
# Rede

# Subnets privadas onde o RDS pode ser colocado
resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

# Libera o PostgreSQL só para o security group do cluster
resource "aws_security_group" "main" {
  name        = "${var.name}-db-sg"
  description = "Acesso ao PostgreSQL a partir do cluster EKS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL a partir do EKS"
    from_port       = 5432
    to_port         = 5432
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
    Name = "${var.name}-db-sg"
  }
}

# ============================================================================
# Senha

# Sem caracteres especiais: "/", "@" e ":" quebram a DATABASE_URL
resource "random_password" "main" {
  length  = 24
  special = false
}

# ============================================================================
# Instância

resource "aws_db_instance" "main" {
  identifier     = "${var.name}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = random_password.main.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
  publicly_accessible    = false
  multi_az               = false

  skip_final_snapshot     = true
  backup_retention_period = 0
}
