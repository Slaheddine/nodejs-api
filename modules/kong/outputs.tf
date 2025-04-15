output "task_definition_arn" {
  description = "The ARN of the Kong task definition"
  value       = aws_ecs_task_definition.kong.arn
}

output "service_id" {
  description = "The ID of the Kong ECS service"
  value       = aws_ecs_service.kong.id
}

output "service_name" {
  description = "The name of the Kong ECS service"
  value       = aws_ecs_service.kong.name
}

output "container_name" {
  description = "The name of the Kong container"
  value       = local.kong_container_name
}

output "container_port" {
  description = "The port of the Kong container"
  value       = var.kong_container_port
}

output "admin_port" {
  description = "The admin port of the Kong container"
  value       = var.kong_admin_port
}
