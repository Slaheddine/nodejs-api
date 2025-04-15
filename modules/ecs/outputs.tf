output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_tasks_security_group_id" {
  description = "The ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "kong_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Kong"
  value       = aws_cloudwatch_log_group.kong.name
}

output "nodejs_api_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Node.js API"
  value       = aws_cloudwatch_log_group.nodejs_api.name
}

output "konga_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Konga"
  value       = aws_cloudwatch_log_group.konga.name
}
