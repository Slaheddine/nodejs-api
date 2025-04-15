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
  description = "The URL of the ECR repository for Konga"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Konga"
  type        = string
}

variable "konga_image_tag" {
  description = "Konga Docker image tag"
  type        = string
  default     = "latest"
}

variable "konga_container_port" {
  description = "Konga container port"
  type        = number
  default     = 1337
}

variable "konga_task_count" {
  description = "Number of Konga ECS tasks to run"
  type        = number
  default     = 1
}

variable "konga_cpu" {
  description = "CPU units for Konga task"
  type        = number
  default     = 256
}

variable "konga_memory" {
  description = "Memory for Konga task in MiB"
  type        = number
  default     = 512
}

variable "kong_admin_url" {
  description = "The URL of the Kong Admin API"
  type        = string
}

variable "db_host" {
  description = "The host of the RDS instance for Konga"
  type        = string
}

variable "db_port" {
  description = "The port of the RDS instance for Konga"
  type        = number
}

variable "db_name" {
  description = "The name of the database for Konga"
  type        = string
}

variable "db_username" {
  description = "The username for the database for Konga"
  type        = string
}

variable "db_password" {
  description = "The password for the database for Konga"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
