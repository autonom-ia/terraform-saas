variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "autonomia"
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = "vpc-0a8017d897d762238" # Default VPC ID from AWS query
}

variable "subnet_a_id" {
  description = "The ID of the first subnet"
  type        = string
  default     = "subnet-07184b6cfa97367e2" # Subnet in us-east-1c
}

variable "subnet_b_id" {
  description = "The ID of the second subnet"
  type        = string
  default     = "subnet-000fbcffe0f8d9a11" # Subnet in us-east-1d
}

variable "database_name" {
  description = "The name of the database"
  type        = string
  default     = "autonomia_db"
}

variable "database_username" {
  description = "The master username for the database"
  type        = string
  default     = "autonomia_admin"
}

variable "database_password" {
  description = "The master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro" # Smallest instance class for PostgreSQL
}

variable "allocated_storage" {
  description = "The amount of allocated storage for the RDS instance in gibibytes"
  type        = number
  default     = 5 # Minimum for gp2 storage
}

variable "rds_security_group_id" {
  description = "The ID of the security group associated with the RDS instance"
  type        = string
  default     = "sg-0e9189ca9e6d0427d" # Security group ID do RDS
}

variable "db_password" {
  description = "The password for the database (for SSM parameter)"
  type        = string
  sensitive   = true
  default     = "" # Será preenchido pelo terraform.tfvars
}

variable "db_password_empresa_cwt" {
  description = "A senha do banco de dados PostgreSQL da empresa Chatwoot"
  type        = string
  sensitive   = true
  default     = "" # Será preenchido pelo terraform.tfvars
}

# Variáveis para o banco de dados de clientes
variable "clients_database_name" {
  description = "O nome do banco de dados de clientes"
  type        = string
  default     = "autonomia_clients"
}

variable "clients_database_username" {
  description = "O nome de usuário para o banco de dados de clientes"
  type        = string
  default     = "autonomia_clients_admin"
}

variable "clients_database_password" {
  description = "A senha para o banco de dados de clientes"
  type        = string
  sensitive   = true
  default     = "" # Será preenchido pelo terraform.tfvars
}
