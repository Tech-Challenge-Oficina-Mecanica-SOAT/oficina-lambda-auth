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

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

module "lambda" {
  source                 = "../../modules/lambda"
  environment            = "homolog"
  lambda_zip_path        = "${path.root}/../../../lambda.zip"
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  lab_role_arn           = data.aws_iam_role.lab_role.arn
}

module "api_gateway" {
  source                      = "../../modules/api-gateway"
  environment                 = "homolog"
  lambda_arn                  = module.lambda.function_arn
  lambda_invoke_arn           = module.lambda.invoke_arn
  lambda_function_name        = module.lambda.function_name
  nlb_endpoint                = var.nlb_endpoint
  vpc_link_subnet_ids         = var.vpc_link_subnet_ids
  vpc_link_security_group_ids = var.vpc_link_security_group_ids

  depends_on = [module.lambda]
}
