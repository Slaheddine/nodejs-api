variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name to be used in resource naming"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}

variable "ecs_tasks_security_group_id" {
  description = "The ID of the security group for ECS tasks"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository for Node.js API"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Node.js API"
  type        = string
}

variable "nodejs_api_image_tag" {
  description = "Node.js API Docker image tag"
  type        = string
  default     = "latest"
}

variable "nodejs_api_container_port" {
  description = "Node.js API container port"
  type        = number
  default     = 3000
}

variable "nodejs_api_task_count" {
  description = "Number of Node.js API ECS tasks to run"
  type        = number
  default     = 2
}

variable "nodejs_api_cpu" {
  description = "CPU units for Node.js API task"
  type        = number
  default     = 256
}

variable "nodejs_api_memory" {
  description = "Memory for Node.js API task in MiB"
  type        = number
  default     = 512
}

variable "cognito_user_pool_id" {
  description = "The ID of the Cognito user pool"
  type        = string
}

variable "cognito_client_id" {
  description = "The ID of the Cognito user pool client"
  type        = string
}

variable "cognito_client_secret" {
  description = "The client secret of the Cognito user pool client"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
