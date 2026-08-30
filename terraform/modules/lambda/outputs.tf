output "function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.auth_cpf.arn
}

output "function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.auth_cpf.function_name
}

output "invoke_arn" {
  description = "ARN de invocação da Lambda (usado pelo API Gateway)"
  value       = aws_lambda_function.auth_cpf.invoke_arn
}
