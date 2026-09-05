variable "environment" {
  description = "Ambiente de execução (homolog ou prod)"
  type        = string
}

variable "lambda_zip_path" {
  description = "Caminho para o arquivo zip da Lambda"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "IDs das subnets privadas (publicadas por P4)"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "IDs dos security groups (publicados por P4)"
  type        = list(string)
}
