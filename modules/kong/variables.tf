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
  description = "The URL of the ECR repository for Kong"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Kong"
  type        = string
}

variable "kong_image_tag" {
  description = "Kong Docker image tag"
  type        = string
  default     = "latest"
}

variable "kong_container_port" {
  description = "Kong container port"
  type        = number
  default     = 8000
}

variable "kong_admin_port" {
  description = "Kong admin port"
  type        = number
  default     = 8001
}

variable "kong_task_count" {
  description = "Number of Kong ECS tasks to run"
  type        = number
  default     = 2
}

variable "kong_cpu" {
  description = "CPU units for Kong task"
  type        = number
  default     = 512
}

variable "kong_memory" {
  description = "Memory for Kong task in MiB"
  type        = number
  default     = 1024
}

variable "db_host" {
  description = "The host of the RDS instance"
  type        = string
}

variable "db_port" {
  description = "The port of the RDS instance"
  type        = number
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_secret_arn" {
  description = "The ARN of the secret containing database credentials"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
