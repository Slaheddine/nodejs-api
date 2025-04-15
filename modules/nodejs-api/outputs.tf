output "task_definition_arn" {
  description = "The ARN of the Node.js API task definition"
  value       = aws_ecs_task_definition.nodejs_api.arn
}

output "service_id" {
  description = "The ID of the Node.js API ECS service"
  value       = aws_ecs_service.nodejs_api.id
}

output "service_name" {
  description = "The name of the Node.js API ECS service"
  value       = aws_ecs_service.nodejs_api.name
}

output "container_name" {
  description = "The name of the Node.js API container"
  value       = local.nodejs_api_container_name
}

output "container_port" {
  description = "The port of the Node.js API container"
  value       = var.nodejs_api_container_port
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the Cognito client secret"
  value       = aws_ssm_parameter.cognito_client_secret.name
}
