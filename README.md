# oficina-lambda-auth

Lambda de autenticação por CPF para o projeto **Oficina Mecânica** (FIAP SOAT — Fase 3).

Recebe um CPF, valida os dígitos verificadores, consulta o cliente no banco PostgreSQL e retorna um JWT compatível com a API principal.

---

## Índice

- [Arquitetura](#arquitetura)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Como rodar localmente](#como-rodar-localmente)
- [Testes](#testes)
- [Build e deploy](#build-e-deploy)
- [Terraform](#terraform)
- [CI/CD](#cicd)
- [Endpoint](#endpoint)

---

## Arquitetura

```
Cliente
  │
  ▼
API Gateway HTTP API v2
  │
  ├── POST /auth/cpf ──────► Lambda (Node.js 20)
  │                               │
  │                               ├── Valida CPF
  │                               ├── Busca secrets (SSM + Secrets Manager)
  │                               ├── Consulta RDS PostgreSQL
  │                               └── Retorna JWT
  │
  ├── ANY /api/{proxy+} ───► VPC Link ──► NLB ──► EKS (API .NET)
  └── ANY /publico/{proxy+}► VPC Link ──► NLB ──► EKS (API .NET)
```

---

## Estrutura do projeto

```
oficina-lambda-auth/
├── src/
│   ├── auth/
│   │   ├── cpfValidator.js       # Validação de CPF com dígitos verificadores
│   │   ├── jwtGenerator.js       # Geração do JWT (HS256, 1h)
│   │   └── clienteRepository.js  # Consulta ao RDS por CPF
│   ├── config/
│   │   └── secrets.js            # Leitura de SSM e Secrets Manager (com cache)
│   ├── errors.js                 # Classes de erro tipadas com statusCode
│   └── handler.js                # Entry point da Lambda
├── tests/
│   └── unit/
│       ├── cpfValidator.test.js
│       └── jwtGenerator.test.js
├── terraform/
│   ├── modules/
│   │   ├── lambda/               # Módulo da função Lambda
│   │   └── api-gateway/          # Módulo do API Gateway HTTP API v2
│   └── envs/
│       └── homolog/              # Ambiente de homologação
├── scripts/
│   ├── build.sh                  # Gera o lambda.zip
│   └── deploy.sh                 # Build + terraform apply + smoke test
└── .github/
    └── workflows/
        ├── ci.yml                # Testes + lint + terraform validate (PR)
        └── deploy.yml            # Build + deploy + smoke test (push)
```

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Node.js | 20 |
| Terraform | 1.9+ |
| AWS CLI | 2.x |
| zip | qualquer |

---

## Como rodar localmente

```bash
# Instalar dependências
npm ci

# Rodar testes
npm test

# Rodar testes com cobertura
npm run test:coverage

# Lint
npm run lint
```

---

## Testes

18 testes unitários cobrindo:

| Arquivo | Casos |
|---|---|
| `cpfValidator.test.js` | CPF válido com/sem máscara, dígitos iguais, tamanho errado, letras, nulo |
| `jwtGenerator.test.js` | Claims corretas, expiração, algoritmo HS256, secret inválido |

```bash
npm test
```

---

## Build e deploy

### Build local

```bash
./scripts/build.sh
# Gera lambda.zip na raiz do projeto
```

### Deploy manual

```bash
# Requer credenciais AWS configuradas
./scripts/deploy.sh homolog
```

---

## Terraform

### Recursos criados

| Recurso | Descrição |
|---|---|
| `aws_lambda_function` | Função Lambda Node.js 20 com VPC config |
| `aws_apigatewayv2_api` | HTTP API v2 com CORS configurado |
| `aws_apigatewayv2_stage` | Stage `$default` com auto-deploy |
| `aws_apigatewayv2_route` | `POST /auth/cpf` → Lambda |
| `aws_apigatewayv2_vpc_link` | VPC Link para rotear `/api/*` ao EKS (quando P3 entregar o NLB) |
| `aws_cloudwatch_log_group` | Logs da Lambda e do API Gateway (retenção 7 dias) |
| `aws_ssm_parameter` | Publica endpoint e ID do API Gateway no Parameter Store |

### Aplicar manualmente

```bash
# 1. Copiar e preencher o tfvars
cp terraform/envs/homolog/terraform.tfvars.example terraform/envs/homolog/terraform.tfvars

# 2. Editar com os valores reais de subnets e security groups (P4)

# 3. Build
./scripts/build.sh

# 4. Apply
cd terraform/envs/homolog
terraform init
terraform apply
```

---

## CI/CD

| Workflow | Trigger | O que faz |
|---|---|---|
| `ci.yml` | PR para `main` ou `homolog` | Lint + testes + terraform validate |
| `deploy.yml` | Push para `homolog` | Build + deploy no ambiente homolog |
| `deploy.yml` | Push para `main` | Build + deploy no ambiente prod |

### Secrets necessários no GitHub

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sessão AWS Academy |

---

## Endpoint

```http
POST /auth/cpf
Content-Type: application/json

{
  "cpf": "12345678909"
}
```

### Respostas

| Status | Descrição |
|---|---|
| `200` | JWT gerado com sucesso |
| `400` | CPF ausente ou inválido |
| `403` | Cliente inativo |
| `404` | Cliente não encontrado |
| `500` | Erro interno |

**Exemplo de resposta 200:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600
}
```
