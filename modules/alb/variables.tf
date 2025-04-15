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

variable "public_subnet_ids" {
  description = "List of IDs of public subnets"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "The ID of the security group for ECS tasks"
  type        = string
}

variable "kong_service_name" {
  description = "The name of the Kong ECS service"
  type        = string
}

variable "kong_container_name" {
  description = "The name of the Kong container"
  type        = string
}

variable "kong_container_port" {
  description = "The port of the Kong container"
  type        = number
}

variable "nodejs_api_service_name" {
  description = "The name of the Node.js API ECS service"
  type        = string
}

variable "nodejs_api_container_name" {
  description = "The name of the Node.js API container"
  type        = string
}

variable "nodejs_api_container_port" {
  description = "The port of the Node.js API container"
  type        = number
}

variable "konga_service_name" {
  description = "The name of the Konga ECS service"
  type        = string
}

variable "konga_container_name" {
  description = "The name of the Konga container"
  type        = string
}

variable "konga_container_port" {
  description = "The port of the Konga container"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
