variable "vpc_subnet_ids" {
  description = "IDs das subnets privadas (publicadas por P4)"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "IDs dos security groups (publicados por P4)"
  type        = list(string)
}

variable "nlb_endpoint" {
  description = "Endpoint do NLB do EKS (publicado por P3) — deixar vazio até P3 entregar"
  type        = string
  default     = ""
}

variable "vpc_link_subnet_ids" {
  description = "IDs das subnets para o VPC Link (publicadas por P4)"
  type        = list(string)
  default     = []
}
