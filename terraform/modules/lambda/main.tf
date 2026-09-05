terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "lab_role_arn" {
  description = "ARN do LabRole da AWS Academy"
  type        = string
}

resource "aws_lambda_function" "auth_cpf" {
  function_name = "oficina-auth-cpf-${var.environment}"
  filename      = var.lambda_zip_path
  role          = var.lab_role_arn
  handler       = "src/handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      ENVIRONMENT                         = var.environment
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

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/oficina-auth-cpf-${var.environment}"
  retention_in_days = 7

  tags = {
    Project     = "oficina-mecanica"
    Environment = var.environment
  }
}
