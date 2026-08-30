variable "vpc_subnet_ids" {
  description = "IDs das subnets privadas (publicadas por P4 no Parameter Store)"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "IDs dos security groups (publicados por P4 no Parameter Store)"
  type        = list(string)
}
