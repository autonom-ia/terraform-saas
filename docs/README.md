# Autonom.ia RDS Terraform Configuration

Este projeto contém a configuração Terraform para criar e gerenciar bancos de dados PostgreSQL RDS na AWS, com suporte para ambientes separados de **Produção** e **Staging**.

## 🎯 Características

- ✅ Suporte para múltiplos ambientes (prod e staging)
- ✅ Separação completa de recursos por ambiente
- ✅ Reutilização de infraestrutura compartilhada (VPC, Security Groups)
- ✅ Parâmetros SSM separados por ambiente
- ✅ Isolamento total entre ambientes

## Pré-requisitos

- Terraform 1.0.0 ou superior
- AWS CLI configurado com credenciais de acesso
- Acesso à AWS com permissões para criar recursos RDS
- Security Group existente (`sg-0e9189ca9e6d0427d`)
- VPC existente (`vpc-0a8017d897d762238`)

## Estrutura do Projeto

- `main.tf` - Configuração principal do Terraform (RDS)
- `variables.tf` - Definição das variáveis utilizadas
- `ssm-parameters.tf` - Parâmetros SSM separados por ambiente
- `elasticache.tf` - Configuração do ElastiCache Redis
- `terraform.tfvars.prod.example` - Exemplo de configuração para produção
- `terraform.tfvars.staging.example` - Exemplo de configuração para staging
- `DEPLOY.md` - Guia completo de deploy por ambiente

## Recursos Criados

- Instância RDS PostgreSQL (separada por ambiente)
- Grupo de sub-redes para o RDS (separado por ambiente)
- Parâmetros SSM (separados por ambiente: `/autonomia/prod/*` e `/autonomia/staging/*`)
- ElastiCache Redis (separado por ambiente)

## 🚀 Deploy por Ambiente

Este projeto suporta deploy separado para produção e staging. **Consulte o arquivo [DEPLOY.md](./DEPLOY.md) para instruções detalhadas.**

### Deploy Rápido (Usando Workspaces)

```bash
# Inicializar
terraform init

# Deploy de Produção
terraform workspace new prod || terraform workspace select prod
cp terraform.tfvars.prod.example terraform.tfvars
# Editar terraform.tfvars com valores corretos
terraform plan
terraform apply

# Deploy de Staging
terraform workspace new staging || terraform workspace select staging
cp terraform.tfvars.staging.example terraform.tfvars
# Editar terraform.tfvars com valores corretos
terraform plan
terraform apply
```

### Configuração

Antes de aplicar, configure os valores no arquivo `terraform.tfvars`:

- **Produção**: Use `terraform.tfvars.prod.example` como base
- **Staging**: Use `terraform.tfvars.staging.example` como base

⚠️ **IMPORTANTE**: Nunca commite arquivos `terraform.tfvars` com senhas reais no Git!

## Conexão ao Banco de Dados

Após a criação do banco de dados, você pode se conectar a ele usando o endpoint fornecido na saída do Terraform:

```bash
psql -h <db_endpoint> -U autonomia_admin -d autonomia_db
```

## 🔒 Segurança

- O banco de dados está configurado para ser acessível pela internet (publicly_accessible = true)
- Utiliza Security Group existente compartilhado entre ambientes
- O grupo de segurança permite tráfego na porta 5432 de qualquer IP (0.0.0.0/0)
- Em um ambiente de produção, considere restringir o acesso a IPs específicos
- Parâmetros SSM com senhas são armazenados como SecureString

## 📊 Verificar Recursos

### Listar Instâncias RDS por Ambiente

```bash
# Verificar workspace atual
terraform workspace show

# Listar todas as instâncias RDS
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,AllocatedStorage,DBInstanceStatus]' --output table
```

### Verificar SSM Parameters

```bash
# Prod
aws ssm get-parameters-by-path --path "/autonomia/prod/" --recursive

# Staging
aws ssm get-parameters-by-path --path "/autonomia/staging/" --recursive
```

## 🗑️ Limpeza

Para destruir os recursos de um ambiente:

```bash
# Selecionar o workspace do ambiente
terraform workspace select prod  # ou staging

# Destruir recursos
terraform destroy
```

⚠️ **ATENÇÃO**: Certifique-se de estar no workspace correto antes de executar `destroy`!
