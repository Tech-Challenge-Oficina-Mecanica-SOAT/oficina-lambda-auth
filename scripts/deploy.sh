#!/usr/bin/env bash
set -euo pipefail

ENV=${1:-homolog}

echo "Deploying to $ENV..."

# Build
./scripts/build.sh

# Apply
cd "terraform/envs/$ENV"
terraform init
terraform apply -auto-approve

# Smoke test
API_URL=$(aws ssm get-parameter --name "/oficina/$ENV/api-gateway/endpoint" --query Parameter.Value --output text)
echo "API Gateway URL: $API_URL"

# Test endpoint (deve retornar 400 - CPF ausente)
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL/auth/cpf" \
  -H "Content-Type: application/json" \
  -d '{}')

if [ "$STATUS" = "400" ]; then
  echo "Smoke test OK - endpoint respondeu 400 como esperado"
else
  echo "AVISO: smoke test retornou $STATUS (esperado 400)"
  exit 1
fi
