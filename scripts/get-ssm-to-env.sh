#!/bin/bash

# Script para buscar senhas do SSM e criar .env.prod ou .env.staging
# Uso: ./scripts/get-ssm-to-env.sh [prod|staging]

ENV=${1:-prod}
REGION="us-east-1"

if [ "$ENV" != "prod" ] && [ "$ENV" != "staging" ]; then
  echo "❌ Erro: Ambiente deve ser 'prod' ou 'staging'"
  exit 1
fi

export AWS_PROFILE=autonomia

echo "🔍 Buscando credenciais do SSM para ambiente: $ENV"
echo ""

# Buscar parâmetros do SSM
DB_PASSWORD=$(aws ssm get-parameter --name "/autonomia/${ENV}/db/password" --with-decryption --region $REGION --query 'Parameter.Value' --output text 2>/dev/null)
CLIENTS_DB_PASSWORD=$(aws ssm get-parameter --name "/autonomia/${ENV}/clients/db/password" --with-decryption --region $REGION --query 'Parameter.Value' --output text 2>/dev/null)

if [ -z "$DB_PASSWORD" ]; then
  echo "⚠️  Não foi possível buscar senhas do SSM"
  echo "💡 Verifique se você tem acesso ao SSM e se os parâmetros existem"
  exit 1
fi

ENV_FILE=".env.${ENV}"

# Converter ENV para maiúsculas (compatível com bash 3.2)
ENV_UPPER=$(echo "$ENV" | tr '[:lower:]' '[:upper:]')
CURRENT_DATE=$(date)

# Criar arquivo .env
cat > "$ENV_FILE" << EOF
# Configuração de Credenciais - $ENV_UPPER
# Gerado automaticamente do SSM em $CURRENT_DATE

# Credenciais do Banco de Dados $ENV_UPPER
TF_VAR_database_password=$DB_PASSWORD
TF_VAR_db_password=$DB_PASSWORD
TF_VAR_clients_database_password=$CLIENTS_DB_PASSWORD
TF_VAR_db_password_empresa_cwt=
EOF

echo "✅ Arquivo $ENV_FILE criado com sucesso!"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Verifique se todas as senhas estão corretas"
echo "   - Preencha TF_VAR_db_password_empresa_cwt se necessário"
echo "   - O arquivo está no .gitignore e não será commitado"
echo ""
echo "📝 Próximo passo:"
echo "   source load-env.sh $ENV"
