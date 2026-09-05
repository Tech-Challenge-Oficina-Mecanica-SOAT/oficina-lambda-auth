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

variable "vpc_link_security_group_ids" {
  description = "Security groups do VPC Link. O SG default da VPC pode não ter regra alguma (ingress/egress); sem um SG que realmente permita o tráfego até o NLB/node do EKS, a integração falha com 503 Service Unavailable."
  type        = list(string)
  default     = []
}
