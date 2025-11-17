# Configuração de Variáveis de Ambiente (.env)

Este projeto usa arquivos `.env.prod` e `.env.staging` separados para armazenar credenciais sensíveis de cada ambiente, evitando que sejam commitadas no Git.

## 📋 Setup Inicial

### Para Produção

1. **Copie o arquivo de exemplo:**
   ```bash
   cp .env.prod.example .env.prod
   ```

2. **Edite o arquivo `.env.prod` com as credenciais de produção:**
   ```bash
   # Credenciais do Banco de Dados PRODUÇÃO
   TF_VAR_database_password=senha_prod_aqui
   TF_VAR_db_password=senha_prod_aqui
   TF_VAR_clients_database_password=senha_clients_prod_aqui
   TF_VAR_db_password_empresa_cwt=senha_chatwoot_aqui
   ```

### Para Staging

1. **Copie o arquivo de exemplo:**
   ```bash
   cp .env.staging.example .env.staging
   ```

2. **Edite o arquivo `.env.staging` com as credenciais de staging:**
   ```bash
   # Credenciais do Banco de Dados STAGING
   TF_VAR_database_password=senha_staging_aqui
   TF_VAR_db_password=senha_staging_aqui
   TF_VAR_clients_database_password=senha_clients_staging_aqui
   TF_VAR_db_password_empresa_cwt=senha_chatwoot_aqui
   ```

## 🚀 Como Usar

### Usando o script helper (Recomendado)

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

### Opção 2: Carregar manualmente

```bash
# No bash/zsh
export $(cat .env | xargs)

# Depois execute terraform
terraform plan
terraform apply
```

### Opção 3: Inline (uma linha)

```bash
# Carregar e executar em um comando
export $(cat .env | xargs) && terraform apply
```

## ⚠️ Importante

- ✅ O arquivo `.env` está no `.gitignore` e **NÃO será commitado**
- ✅ Sempre use `.env.example` como referência
- ✅ Nunca commite o arquivo `.env` com credenciais reais
- ✅ Cada desenvolvedor deve criar seu próprio `.env` local

## 📝 Variáveis que vêm do .env

As seguintes variáveis sensíveis devem estar no `.env`:

- `TF_VAR_database_password` - Senha do banco principal
- `TF_VAR_db_password` - Senha para SSM (geralmente igual a database_password)
- `TF_VAR_clients_database_password` - Senha do banco de clientes
- `TF_VAR_db_password_empresa_cwt` - Senha do Chatwoot (opcional)

## 🔍 Verificar se as variáveis foram carregadas

```bash
# Carregar o .env
source load-env.sh

# Verificar se as variáveis estão definidas (não mostrará os valores por segurança)
env | grep TF_VAR
```

## 🐛 Troubleshooting

### Erro: "Required variable not set"
- Certifique-se de ter criado o arquivo `.env`
- Verifique se executou `source load-env.sh` antes do terraform
- Confirme que as variáveis no `.env` começam com `TF_VAR_`

### Erro: "Invalid value for variable"
- Verifique se não há espaços extras no `.env`
- Certifique-se de que não há aspas desnecessárias nos valores

