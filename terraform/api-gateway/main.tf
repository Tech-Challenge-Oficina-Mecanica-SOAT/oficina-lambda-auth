terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ─── API Gateway HTTP API v2 ──────────────────────────────────

resource "aws_apigatewayv2_api" "main" {
  name          = "oficina-mecanica-${var.environment}"
  protocol_type = "HTTP"
  description   = "API Gateway da Oficina Mecânica — ${var.environment}"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ─── Stage ───────────────────────────────────────────────────

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
  }

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}

# ─── CloudWatch Log Group ─────────────────────────────────────

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/oficina-mecanica-${var.environment}"
  retention_in_days = 7

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}

# ─── Integração Lambda (POST /auth/cpf) ──────────────────────

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_cpf" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /auth/cpf"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# ─── VPC Link + Integração EKS (/api/* e /publico/*) ─────────
# Criado apenas se o endpoint do NLB for fornecido por P3

resource "aws_apigatewayv2_vpc_link" "eks" {
  count              = var.nlb_endpoint != "" ? 1 : 0
  name               = "oficina-vpc-link-${var.environment}"
  security_group_ids = []
  subnet_ids         = var.vpc_link_subnet_ids

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "eks" {
  count              = var.nlb_endpoint != "" ? 1 : 0
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${var.nlb_endpoint}/{proxy}"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks[0].id
}

resource "aws_apigatewayv2_route" "api_proxy" {
  count     = var.nlb_endpoint != "" ? 1 : 0
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks[0].id}"
}

resource "aws_apigatewayv2_route" "publico_proxy" {
  count     = var.nlb_endpoint != "" ? 1 : 0
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /publico/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks[0].id}"
}

# ─── Publicar endpoint no Parameter Store ────────────────────

resource "aws_ssm_parameter" "api_gateway_endpoint" {
  name  = "/oficina/${var.environment}/api-gateway/endpoint"
  type  = "String"
  value = aws_apigatewayv2_api.main.api_endpoint

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "api_gateway_id" {
  name  = "/oficina/${var.environment}/api-gateway/id"
  type  = "String"
  value = aws_apigatewayv2_api.main.id

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}
