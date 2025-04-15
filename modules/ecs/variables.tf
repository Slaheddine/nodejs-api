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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
  default     = null
}

variable "ecs_task_role_name" {
  description = "Name of the ECS task role"
  type        = string
  default     = null
}
