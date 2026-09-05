variable "environment" {
  description = "Ambiente de execução (homolog ou prod)"
  type        = string
}

variable "lambda_arn" {
  description = "ARN da função Lambda"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN de invocação da Lambda"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "nlb_endpoint" {
  description = "Endpoint do NLB do EKS (publicado por P3)"
  type        = string
  default     = ""
}

variable "vpc_link_subnet_ids" {
  description = "IDs das subnets para o VPC Link"
  type        = list(string)
  default     = []
}
