output "api_endpoint" {
  description = "URL pública do API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_id" {
  description = "ID do API Gateway"
  value       = aws_apigatewayv2_api.main.id
}
