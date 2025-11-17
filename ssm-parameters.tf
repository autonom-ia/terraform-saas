/**
 * Configuração Terraform para criação dos parâmetros SSM
 * Estes parâmetros serão usados pela função Lambda
 */

# Parâmetros do banco de dados da empresta Chatwoot
resource "aws_ssm_parameter" "empresta_chatwoot_db_host" {
  name        = "/empresta/chatwoot/db/host"
  description = "Host do banco de dados PostgreSQL da empresta Chatwoot"
  type        = "String"
  value       = "31.97.240.26"
  overwrite   = true
}

resource "aws_ssm_parameter" "empresta_chatwoot_db_port" {
  name        = "/empresta/chatwoot/db/port"
  description = "Porta do banco de dados PostgreSQL da empresta Chatwoot"
  type        = "String"
  value       = "5432"
  overwrite   = true
}

resource "aws_ssm_parameter" "empresta_chatwoot_db_name" {
  name        = "/empresta/chatwoot/db/name"
  description = "Nome do banco de dados PostgreSQL da empresta Chatwoot"
  type        = "String"
  value       = "chatwoot"
  overwrite   = true
}

resource "aws_ssm_parameter" "empresta_chatwoot_db_user" {
  name        = "/empresta/chatwoot/db/user"
  description = "Usuário do banco de dados PostgreSQL da empresta Chatwoot"
  type        = "String"
  value       = "postgres"
  overwrite   = true
}

resource "aws_ssm_parameter" "empresta_chatwoot_db_password" {
  count       = var.db_password_empresa_cwt != "" ? 1 : 0
  name        = "/empresta/chatwoot/db/password"
  description = "Senha do banco de dados PostgreSQL da empresta Chatwoot"
  type        = "SecureString"
  value       = var.db_password_empresa_cwt
  overwrite   = true
}

# Parâmetros do banco de dados da autonomia Chatwoot
resource "aws_ssm_parameter" "autonomia_chatwoot_db_host" {
  name        = "/autonomia/chatwoot/db/host"
  description = "Host do banco de dados PostgreSQL da autonomia Chatwoot"
  type        = "String"
  value       = "46.202.149.38"
  overwrite   = true
}

resource "aws_ssm_parameter" "autonomia_chatwoot_db_port" {
  name        = "/autonomia/chatwoot/db/port"
  description = "Porta do banco de dados PostgreSQL da autonomia Chatwoot"
  type        = "String"
  value       = "5432"
  overwrite   = true
}

resource "aws_ssm_parameter" "autonomia_chatwoot_db_name" {
  name        = "/autonomia/chatwoot/db/name"
  description = "Nome do banco de dados PostgreSQL da autonomia Chatwoot"
  type        = "String"
  value       = "chatwoot"
  overwrite   = true
}

resource "aws_ssm_parameter" "autonomia_chatwoot_db_user" {
  name        = "/autonomia/chatwoot/db/user"
  description = "Usuário do banco de dados PostgreSQL da autonomia Chatwoot"
  type        = "String"
  value       = "postgres"
  overwrite   = true
}

resource "aws_ssm_parameter" "autonomia_chatwoot_db_password" {
  count       = var.db_password_empresa_cwt != "" ? 1 : 0
  name        = "/autonomia/chatwoot/db/password"
  description = "Senha do banco de dados PostgreSQL da autonomia Chatwoot"
  type        = "SecureString"
  value       = var.db_password_empresa_cwt
  overwrite   = true
}

# Parâmetros do banco de dados
resource "aws_ssm_parameter" "db_host" {
  name        = "/autonomia/${var.environment}/db/host"
  description = "Host do banco de dados PostgreSQL"
  type        = "String"
  value       = aws_db_instance.main.address
  overwrite   = true
}

resource "aws_ssm_parameter" "db_port" {
  name        = "/autonomia/${var.environment}/db/port"
  description = "Porta do banco de dados PostgreSQL"
  type        = "String"
  value       = "5432"
  overwrite   = true
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/autonomia/${var.environment}/db/name"
  description = "Nome do banco de dados PostgreSQL"
  type        = "String"
  value       = "autonomia_db"
  overwrite   = true
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/autonomia/${var.environment}/db/user"
  description = "Usuário do banco de dados PostgreSQL"
  type        = "String"
  value       = var.database_username
  overwrite   = true
}

# Parâmetros para o banco de dados de clientes (separados por ambiente)
resource "aws_ssm_parameter" "clients_db_host" {
  name        = "/autonomia/${var.environment}/clients/db/host"
  description = "Host do banco de dados PostgreSQL de clientes"
  type        = "String"
  value       = aws_db_instance.main.address
  overwrite   = true
}

resource "aws_ssm_parameter" "clients_db_port" {
  name        = "/autonomia/${var.environment}/clients/db/port"
  description = "Porta do banco de dados PostgreSQL de clientes"
  type        = "String"
  value       = "5432"
  overwrite   = true
}

resource "aws_ssm_parameter" "clients_db_name" {
  name        = "/autonomia/${var.environment}/clients/db/name"
  description = "Nome do banco de dados PostgreSQL de clientes"
  type        = "String"
  value       = var.clients_database_name
  overwrite   = true
}

resource "aws_ssm_parameter" "clients_db_user" {
  name        = "/autonomia/${var.environment}/clients/db/user"
  description = "Usuário do banco de dados PostgreSQL de clientes"
  type        = "String"
  value       = var.clients_database_username
  overwrite   = true
}

resource "aws_ssm_parameter" "clients_db_password" {
  name        = "/autonomia/${var.environment}/clients/db/password"
  description = "Senha do banco de dados PostgreSQL de clientes"
  type        = "SecureString"
  value       = var.clients_database_password
  overwrite   = true
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/autonomia/${var.environment}/db/password"
  description = "Senha do banco de dados PostgreSQL"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true
}

resource "aws_ssm_parameter" "db_ssl_enabled" {
  name        = "/autonomia/${var.environment}/db/ssl-enabled"
  description = "Flag para habilitar SSL no banco de dados PostgreSQL"
  type        = "String"
  value       = "true"
  overwrite   = true
}


# O parâmetro de security group foi removido, pois não é necessário para a Lambda
# O security group será referenciado diretamente no arquivo serverless-api.yml

# Os parâmetros de subnet foram removidos, pois não são necessários para a Lambda
# As subnets serão referenciadas diretamente no arquivo serverless-api.yml
