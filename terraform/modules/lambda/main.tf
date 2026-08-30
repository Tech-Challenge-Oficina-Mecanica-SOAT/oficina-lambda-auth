terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ─── Data sources ────────────────────────────────────────────

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_ssm_parameter" "db_endpoint" {
  name = "/oficina/${var.environment}/db/endpoint"
}

data "aws_ssm_parameter" "db_port" {
  name = "/oficina/${var.environment}/db/port"
}

data "aws_ssm_parameter" "db_name" {
  name = "/oficina/${var.environment}/db/name"
}

data "aws_ssm_parameter" "db_username" {
  name = "/oficina/${var.environment}/db/username"
}

# ─── Lambda Function ─────────────────────────────────────────

resource "aws_lambda_function" "auth_cpf" {
  function_name = "oficina-auth-cpf-${var.environment}"
  filename      = var.lambda_zip_path
  role          = data.aws_iam_role.lab_role.arn
  handler       = "src/handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      ENVIRONMENT = var.environment
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ─── CloudWatch Log Group ─────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/oficina-auth-cpf-${var.environment}"
  retention_in_days = 7

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}
