#!/bin/bash

# Script para resetar senha do RDS para a senha do SSM
# Uso: ./scripts/resetar-senha-rds.sh [staging|prod]

ENV=${1:-staging}
REGION="us-east-1"
DB_IDENTIFIER="autonomia-${ENV}-db"

export AWS_PROFILE=autonomia

echo "🔐 Resetando senha do RDS ${ENV}..."
echo ""

# Buscar senha do SSM
SSM_PASSWORD=$(aws ssm get-parameter --name "/autonomia/${ENV}/db/password" --with-decryption --region $REGION --query 'Parameter.Value' --output text 2>/dev/null)

if [ -z "$SSM_PASSWORD" ]; then
  echo "❌ Erro: Senha não encontrada no SSM"
  echo "💡 Crie o parâmetro /autonomia/${ENV}/db/password no SSM primeiro"
  exit 1
fi

echo "✅ Senha encontrada no SSM"
echo "📝 Resetando senha do RDS para a senha do SSM..."
echo ""

# Resetar senha do RDS
aws rds modify-db-instance \
  --db-instance-identifier $DB_IDENTIFIER \
  --master-user-password "$SSM_PASSWORD" \
  --apply-immediately \
  --region $REGION \
  --output json > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "✅ Senha do RDS será resetada em alguns minutos"
  echo "⏳ Aguarde a conclusão da modificação (pode levar 2-5 minutos)"
  echo ""
  echo "📊 Verificar status:"
  echo "   aws rds describe-db-instances --db-instance-identifier $DB_IDENTIFIER --region $REGION --query 'DBInstances[0].DBInstanceStatus' --output text"
  echo ""
  echo "💡 Após a modificação, você poderá conectar com:"
  echo "   User: autonomia_admin"
  echo "   Password: [senha do SSM]"
else
  echo "❌ Erro ao resetar senha"
  echo "💡 Verifique se você tem permissões para modificar o RDS"
  exit 1
fi

