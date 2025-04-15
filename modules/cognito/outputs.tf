output "user_pool_id" {
  description = "The ID of the user pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "The ARN of the user pool"
  value       = aws_cognito_user_pool.main.arn
}

output "client_id" {
  description = "The ID of the user pool client"
  value       = aws_cognito_user_pool_client.api_client.id
}

output "client_secret" {
  description = "The client secret of the user pool client"
  value       = aws_cognito_user_pool_client.api_client.client_secret
  sensitive   = true
}

output "domain" {
  description = "The domain name of the user pool"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "domain_aws_account_id" {
  description = "The AWS account ID for the user pool domain"
  value       = aws_cognito_user_pool_domain.main.aws_account_id
}

output "resource_server_id" {
  description = "The ID of the resource server"
  value       = aws_cognito_resource_server.api.id
}

output "resource_server_scope_identifiers" {
  description = "The scope identifiers of the resource server"
  value       = [
    "${aws_cognito_resource_server.api.identifier}/read",
    "${aws_cognito_resource_server.api.identifier}/write"
  ]
}
