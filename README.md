# Terraform SaaS - Autonomia

Infraestrutura como Código (IaC) para os ambientes de produção e staging da Autonomia.

## 📚 Documentação

Toda a documentação está na pasta [`docs/`](./docs/):

- **[README.md](./docs/README.md)** - Documentação principal do projeto
- **[DEPLOY.md](./docs/DEPLOY.md)** - Guia de deploy para prod e staging
- **[ENV_SETUP.md](./docs/ENV_SETUP.md)** - Configuração de variáveis de ambiente
- **[COST_OPTIMIZATION.md](./docs/COST_OPTIMIZATION.md)** - Otimização de custos
- **[ECONOMIA_STAGING.md](./docs/ECONOMIA_STAGING.md)** - Estratégias de economia para staging
- **[CRIAR_DATABASE_CLIENTS.md](./docs/CRIAR_DATABASE_CLIENTS.md)** - Como criar o database clients

## 🚀 Quick Start

### Setup Inicial

```bash
# 1. Configurar credenciais de produção
cp .env.prod.example .env.prod
# Editar .env.prod com suas credenciais

# 2. Configurar credenciais de staging
cp .env.staging.example .env.staging
# Editar .env.staging com suas credenciais

# 3. Inicializar Terraform
terraform init
```

### Deploy

```bash
# Para PRODUÇÃO
source load-env.sh prod
terraform workspace select prod
terraform plan
terraform apply

# Para STAGING
source load-env.sh staging
terraform workspace select staging
terraform plan
terraform apply
```

## 📋 Recursos Gerenciados

- **RDS PostgreSQL** - Banco de dados principal
- **SSM Parameters** - Parâmetros de configuração
- **ElastiCache Redis** - Cache (opcional)
- **S3 + CloudFront** - Frontend e Knowledge Base (opcional)

## 🔐 Segurança

- Credenciais sensíveis são armazenadas em `.env.prod` e `.env.staging`
- Arquivos `.env*` estão no `.gitignore` e não são commitados
- Use sempre os arquivos `.example` como referência

## 📖 Mais Informações

Consulte a [documentação completa](./docs/) para mais detalhes.
