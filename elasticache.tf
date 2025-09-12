/**
 * Configuração do ElastiCache Redis para a função Lambda
 */

resource "aws_elasticache_subnet_group" "autonomia_cache_subnet_group" {
  name       = "${var.project}-${var.environment}-cache-subnet-group"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]

  tags = {
    Name        = "${var.project}-cache-subnet-group"
    Environment = var.environment
    Project     = var.project
  }
}

# Usaremos diretamente o Security Group do RDS para o ElastiCache
# Não há necessidade de criar um novo security group

resource "aws_elasticache_cluster" "autonomia_cache" {
  cluster_id           = "${var.project}-${var.environment}-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"  # Tipo menor/mais econômico
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.autonomia_cache_subnet_group.name
  security_group_ids   = [var.rds_security_group_id]  # Usar o mesmo security group do RDS

  tags = {
    Name        = "${var.project}-cache"
    Environment = var.environment
    Project     = var.project
  }
}

# Não vamos criar Security Group para a Lambda - usaremos o mesmo do RDS

# Não precisamos mais dos data sources já que estamos usando as variáveis
# VPC e subnets são definidas em variables.tf e terraform.tfvars

# Não precisamos adicionar regras de security group, pois usaremos o mesmo do RDS

# Parâmetros do SSM para armazenar as configurações do Redis
resource "aws_ssm_parameter" "redis_host" {
  name        = "/autonomia/${var.environment}/redis/host"
  description = "Host do Redis ElastiCache"
  type        = "String"
  value       = aws_elasticache_cluster.autonomia_cache.cache_nodes.0.address
  overwrite   = true
}

resource "aws_ssm_parameter" "redis_port" {
  name        = "/autonomia/${var.environment}/redis/port"
  description = "Porta do Redis ElastiCache"
  type        = "String"
  value       = "6379"
  overwrite   = true
}

resource "aws_ssm_parameter" "cache_ttl" {
  name        = "/autonomia/${var.environment}/cache/ttl"
  description = "Tempo de vida do cache em segundos"
  type        = "String"
  value       = "300"  # 5 minutos por padrão
  overwrite   = true
}

# O parâmetro de security group da Lambda foi removido conforme solicitado
# O security group será referenciado diretamente no arquivo serverless-api.yml
