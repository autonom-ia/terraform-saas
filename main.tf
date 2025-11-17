terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "autonomia"

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Usando diretamente as variáveis de vpc_id e subnet_ids definidas em variables.tf

# Usando o Security Group existente ao invés de criar um novo
# O Security Group será referenciado através da variável rds_security_group_id

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

  engine            = "postgres"
  engine_version    = "13.20" # Versão atual do RDS prod (ajustar conforme necessário)
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2" # gp2 permite mínimo de 5GB, enquanto gp3 requer mínimo de 20GB

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 5432

  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  # Make the database accessible from the internet
  publicly_accessible = true

  # Configurações mínimas para economia
  backup_retention_period = 0 # Desabilita backups automáticos
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  multi_az                = false # Sem alta disponibilidade

  # Performance and monitoring - configurações mínimas
  performance_insights_enabled = false
  monitoring_interval          = 0

  # Other settings
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = false # Economiza recursos
  deletion_protection        = false
  skip_final_snapshot        = true # Não cria snapshot ao deletar

  tags = {
    Name = "${var.project}-${var.environment}-db"
  }
}

# Criar database e usuário autonomia_clients automaticamente (se psql estiver disponível)
# Caso contrário, execute manualmente o script: scripts/create-clients-database.sql
resource "null_resource" "create_clients_database" {
  depends_on = [aws_db_instance.main]

  # Executar apenas quando o RDS estiver disponível
  triggers = {
    db_endpoint = aws_db_instance.main.endpoint
    db_name     = var.clients_database_name
    db_user     = var.clients_database_username
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Verificar se psql está disponível
      if ! command -v psql &> /dev/null; then
        echo "⚠️  psql não encontrado. Execute manualmente após o RDS estar disponível:"
        echo "   psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres"
        echo "   E execute os comandos em: scripts/create-clients-database.sql"
        exit 0
      fi
      
      # Aguardar RDS estar disponível (máximo 10 minutos)
      echo "Aguardando RDS estar disponível..."
      for i in {1..60}; do
        if PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -c '\q' 2>/dev/null; then
          echo "✅ RDS está disponível!"
          break
        fi
        if [ $i -eq 60 ]; then
          echo "⚠️  Timeout aguardando RDS. Execute manualmente depois."
          exit 0
        fi
        sleep 10
      done
      
      # Criar database se não existir
      if ! PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${var.clients_database_name}'" | grep -q 1; then
        echo "Criando database ${var.clients_database_name}..."
        PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -c "CREATE DATABASE ${var.clients_database_name};"
      else
        echo "Database ${var.clients_database_name} já existe."
      fi
      
      # Criar usuário se não existir
      if ! PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -tAc "SELECT 1 FROM pg_user WHERE usename='${var.clients_database_username}'" | grep -q 1; then
        echo "Criando usuário ${var.clients_database_username}..."
        PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -c "CREATE USER ${var.clients_database_username} WITH PASSWORD '${var.clients_database_password}';"
      else
        echo "Usuário ${var.clients_database_username} já existe."
      fi
      
      # Conceder permissões
      echo "Concedendo permissões..."
      PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${var.clients_database_name} TO ${var.clients_database_username};"
      PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d ${var.clients_database_name} -c "GRANT ALL ON SCHEMA public TO ${var.clients_database_username};"
      PGPASSWORD='${var.database_password}' psql -h ${aws_db_instance.main.address} -U ${var.database_username} -d ${var.clients_database_name} -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${var.clients_database_username};"
      
      echo "✅ Database ${var.clients_database_name} criado com sucesso!"
    EOT
  }
}

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
