# Guia de Deploy - Ambientes Prod e Staging

Este guia explica como fazer deploy dos ambientes de produção e staging de forma separada.

## 📋 Pré-requisitos

- Terraform >= 1.0.0 instalado
- AWS CLI configurado com credenciais válidas
- Acesso aos recursos AWS (VPC, Security Groups, etc.)

## 🔐 Configuração de Credenciais (.env)

**IMPORTANTE**: As senhas do banco de dados são lidas do arquivo `.env` para evitar commit no Git.

1. **Criar arquivo .env:**
   ```bash
   cp .env.example .env
   ```

2. **Editar o .env com as credenciais reais**

3. **Carregar as variáveis antes de executar terraform:**
   ```bash
   source load-env.sh
   # ou
   export $(cat .env | grep -v '^#' | xargs)
   ```

📖 **Consulte [ENV_SETUP.md](./ENV_SETUP.md) para mais detalhes**

## 🚀 Opção 1: Usando Workspaces do Terraform (Recomendado)

### Inicialização

```bash
# Inicializar o Terraform
terraform init
```

### Deploy de Produção

```bash
# Criar/selecionar workspace de produção
terraform workspace new prod 2>/dev/null || terraform workspace select prod

# Configurar credenciais (se ainda não fez)
cp .env.prod.example .env.prod
# Editar .env.prod com as credenciais de produção

# Carregar variáveis do .env.prod
source load-env.sh prod

# Copiar arquivo de exemplo e ajustar valores
cp terraform.tfvars.prod.example terraform.tfvars
# Editar terraform.tfvars com os valores corretos (sem senhas)

# Verificar o plano
terraform plan

# Aplicar as mudanças
terraform apply
```

### Deploy de Staging

```bash
# Criar/selecionar workspace de staging
terraform workspace new staging 2>/dev/null || terraform workspace select staging

# Configurar credenciais (se ainda não fez)
cp .env.staging.example .env.staging
# Editar .env.staging com as credenciais de staging

# Carregar variáveis do .env.staging
source load-env.sh staging

# Copiar arquivo de exemplo e ajustar valores
cp terraform.tfvars.staging.example terraform.tfvars
# Editar terraform.tfvars com os valores corretos (sem senhas)

# Verificar o plano
terraform plan

# Aplicar as mudanças
terraform apply
```

### Verificar Workspace Atual

```bash
terraform workspace show
```

### Listar Workspaces

```bash
terraform workspace list
```

## 🚀 Opção 2: Usando Arquivos Separados

### Deploy de Produção

```bash
# Copiar arquivo de exemplo
cp terraform.tfvars.prod.example terraform.tfvars.prod
# Editar terraform.tfvars.prod com os valores corretos

# Verificar o plano
terraform plan -var-file="terraform.tfvars.prod"

# Aplicar as mudanças
terraform apply -var-file="terraform.tfvars.prod"
```

### Deploy de Staging

```bash
# Copiar arquivo de exemplo
cp terraform.tfvars.staging.example terraform.tfvars.staging
# Editar terraform.tfvars.staging com os valores corretos

# Verificar o plano
terraform plan -var-file="terraform.tfvars.staging"

# Aplicar as mudanças
terraform apply -var-file="terraform.tfvars.staging"
```

## 📊 Verificar Recursos Criados

### Listar Instâncias RDS

```bash
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,AllocatedStorage,DBInstanceStatus]' --output table
```

### Verificar SSM Parameters

```bash
# Prod
aws ssm get-parameter --name "/autonomia/prod/db/host"

# Staging
aws ssm get-parameter --name "/autonomia/staging/db/host"
```

### Listar Todos os Parâmetros SSM

```bash
# Prod
aws ssm get-parameters-by-path --path "/autonomia/prod/" --recursive

# Staging
aws ssm get-parameters-by-path --path "/autonomia/staging/" --recursive
```

## ⚠️ Importante

1. **Senhas**: Nunca commite arquivos `terraform.tfvars` com senhas reais no Git
2. **State Files**: Cada workspace tem seu próprio state file, garantindo isolamento
3. **Validação**: Sempre execute `terraform plan` antes de `terraform apply`
4. **Ambiente**: Verifique sempre o workspace atual antes de fazer deploy

## 🔧 Troubleshooting

### Erro: "Workspace already exists"
- Use `terraform workspace select <nome>` ao invés de `new`

### Erro: "Resource already exists"
- Verifique se você está no workspace correto
- Verifique se o recurso já existe na AWS

### Erro: "Invalid security group"
- Verifique se o Security Group ID está correto
- Verifique se você tem permissões para usar o Security Group

## 📝 Notas

- Os recursos de rede (VPC, Security Groups, Subnets) são compartilhados entre ambientes
- Cada ambiente terá seu próprio RDS instance
- Os SSM parameters são completamente separados por ambiente (`/autonomia/prod/*` e `/autonomia/staging/*`)


