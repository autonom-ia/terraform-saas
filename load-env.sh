#!/bin/bash

# Script para carregar variáveis de ambiente do arquivo .env
# Uso: source load-env.sh [prod|staging]
# Se não especificar, usa staging como padrão

ENV=${1:-staging}

if [ "$ENV" != "prod" ] && [ "$ENV" != "staging" ]; then
  echo "❌ Erro: Ambiente deve ser 'prod' ou 'staging'"
  echo "Uso: source load-env.sh [prod|staging]"
  return 1 2>/dev/null || exit 1
fi

ENV_FILE=".env.${ENV}"

if [ ! -f "$ENV_FILE" ]; then
  echo "⚠️  Arquivo $ENV_FILE não encontrado!"
  echo "💡 Crie o arquivo baseado no exemplo:"
  echo "   cp .env.${ENV}.example .env.${ENV}"
  echo "   # Depois edite .env.${ENV} com suas credenciais"
  return 1 2>/dev/null || exit 1
fi

# Carregar variáveis do arquivo .env
export $(cat "$ENV_FILE" | grep -v '^#' | grep -v '^$' | xargs)

echo "✅ Variáveis do .env.${ENV} carregadas!"
echo "🚀 Ambiente: ${ENV}"
echo "🚀 Agora você pode executar: terraform plan ou terraform apply"
