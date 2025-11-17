#!/bin/bash

# Script para verificar e corrigir senha do RDS staging
# Uso: ./scripts/verificar-senha-rds.sh [staging|prod]

ENV=${1:-staging}
REGION="us-east-1"
DB_IDENTIFIER="autonomia-${ENV}-db"

export AWS_PROFILE=autonomia

echo "🔍 Verificando configuração do RDS ${ENV}..."
echo ""

# Buscar informações do RDS
DB_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_IDENTIFIER --region $REGION --query 'DBInstances[0].Endpoint.Address' --output text 2>/dev/null)
DB_USER=$(aws rds describe-db-instances --db-instance-identifier $DB_IDENTIFIER --region $REGION --query 'DBInstances[0].MasterUsername' --output text 2>/dev/null)
PUBLICLY_ACCESSIBLE=$(aws rds describe-db-instances --db-instance-identifier $DB_IDENTIFIER --region $REGION --query 'DBInstances[0].PubliclyAccessible' --output text 2>/dev/null)

echo "📊 Informações do RDS:"
echo "   Endpoint: $DB_ENDPOINT"
echo "   Usuário: $DB_USER"
echo "   Publicamente Acessível: $PUBLICLY_ACCESSIBLE"
echo ""

# Buscar senha do SSM
SSM_PASSWORD=$(aws ssm get-parameter --name "/autonomia/${ENV}/db/password" --with-decryption --region $REGION --query 'Parameter.Value' --output text 2>/dev/null)

if [ -z "$SSM_PASSWORD" ]; then
  echo "⚠️  Senha não encontrada no SSM"
else
  echo "✅ Senha encontrada no SSM (primeiros 10 caracteres): ${SSM_PASSWORD:0:10}..."
fi

echo ""
echo "🔐 Para conectar no DBeaver, use:"
echo "   Host: $DB_ENDPOINT"
echo "   Port: 5432"
echo "   Database: autonomia_db"
echo "   User: $DB_USER"
echo "   Password: [a senha do SSM ou do .env.${ENV}]"
echo ""
echo "💡 Se a senha não funcionar:"
echo "   1. Verifique o arquivo .env.${ENV} (senha usada na criação)"
echo "   2. Ou resete a senha do RDS via AWS Console"
echo "   3. Depois atualize o SSM com a senha correta"

