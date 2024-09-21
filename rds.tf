# Criando Security Group para o RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = module.vpc.vpc_id  # Referência da VPC retornada pelo módulo

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Criando o DB Subnet Group usando as subnets privadas do módulo
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets  # Referência das subnets privadas do módulo

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_kms_key" "rds_kms" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
}

# Criando o RDS PostgreSQL
resource "aws_db_instance" "descomplica_postgres" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "13.14"
  instance_class       = "db.t3.medium"
  db_name              = "descomplica_database"
  username             = "descomplicaadmin"
  password             = "descomplica_teste"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Configurações de criptografia
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_kms.arn

  # Backups automáticos
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  # Alta disponibilidade (Multi-AZ)
  multi_az = true

  # Impedir criação de snapshot final
  skip_final_snapshot = true

  # Proteção contra exclusão
  deletion_protection = false

  # Logs no CloudWatch
  enabled_cloudwatch_logs_exports = ["postgresql"]

  depends_on = [
    module.vpc,
    aws_security_group.rds_sg
  ]

  tags = {
    Name = "descomplica-db"
  }
}