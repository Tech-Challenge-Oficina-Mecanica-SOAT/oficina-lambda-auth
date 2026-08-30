terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source                 = "../../modules/lambda"
  environment            = "homolog"
  lambda_zip_path        = "${path.root}/../../../lambda.zip"
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
}

module "api_gateway" {
  source               = "../../modules/api-gateway"
  environment          = "homolog"
  lambda_arn           = module.lambda.function_arn
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name

  depends_on = [module.lambda]
}
