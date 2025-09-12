terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Usando diretamente as variáveis de vpc_id e subnet_ids definidas em variables.tf

# Create security group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL traffic from anywhere (for internet access)
  # In production, you would want to restrict this to specific IPs
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow PostgreSQL traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project}-${var.environment}-rds-sg"
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.environment}-subnet-group"
  description = "DB subnet group for ${var.project} ${var.environment}"
  subnet_ids  = [var.subnet_a_id, var.subnet_b_id]

  tags = {
    Name = "${var.project}-${var.environment}-subnet-group"
  }
}

# Create RDS instance
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-db"

  engine               = "postgres"
  engine_version       = "13"  # Versão mais econômica do PostgreSQL
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = "gp2"  # gp2 permite mínimo de 5GB, enquanto gp3 requer mínimo de 20GB
  
  db_name              = var.database_name
  username             = var.database_username
  password             = var.database_password
  port                 = 5432

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # Make the database accessible from the internet
  publicly_accessible    = true
  
  # Configurações mínimas para economia
  backup_retention_period = 0  # Desabilita backups automáticos
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  multi_az                = false  # Sem alta disponibilidade
  
  # Performance and monitoring - configurações mínimas
  performance_insights_enabled = false
  monitoring_interval         = 0
  
  # Other settings
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = false  # Economiza recursos
  deletion_protection        = false
  skip_final_snapshot        = true  # Não cria snapshot ao deletar
  
  tags = {
    Name = "${var.project}-${var.environment}-db"
  }
}

# NOTA: O banco de dados autonomia_clients deve ser criado manualmente no RDS existente
# usando os seguintes comandos SQL:
# CREATE DATABASE autonomia_clients;
# CREATE USER autonomia_clients_admin WITH PASSWORD 'sua_senha_aqui';
# GRANT ALL PRIVILEGES ON DATABASE autonomia_clients TO autonomia_clients_admin;
#
# Os parâmetros SSM serão criados automaticamente para referência na aplicação

# Output the database endpoint
output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "clients_db_name" {
  description = "The name of the clients database"
  value       = var.clients_database_name
}

output "clients_db_username" {
  description = "The username for the clients database"
  value       = var.clients_database_username
  sensitive   = true
}
