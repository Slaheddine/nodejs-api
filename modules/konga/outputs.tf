output "task_definition_arn" {
  description = "The ARN of the Konga task definition"
  value       = aws_ecs_task_definition.konga.arn
}

output "service_id" {
  description = "The ID of the Konga ECS service"
  value       = aws_ecs_service.konga.id
}

output "service_name" {
  description = "The name of the Konga ECS service"
  value       = aws_ecs_service.konga.name
}

output "container_name" {
  description = "The name of the Konga container"
  value       = local.konga_container_name
}

output "container_port" {
  description = "The port of the Konga container"
  value       = var.konga_container_port
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the Konga database password"
  value       = aws_ssm_parameter.konga_db_password.name
}
