variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name to be used in resource naming"
  type        = string
  default     = "api-platform"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

# RDS variables
variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "kong"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "kong"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

# Cognito variables
variable "callback_urls" {
  description = "List of allowed callback URLs for the identity providers"
  type        = list(string)
  default     = ["https://localhost/oauth2/callback"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the identity providers"
  type        = list(string)
  default     = ["https://localhost/logout"]
}

# ECS variables
variable "kong_image_tag" {
  description = "Kong Docker image tag"
  type        = string
  default     = "latest"
}

variable "nodejs_api_image_tag" {
  description = "Node.js API Docker image tag"
  type        = string
  default     = "latest"
}

variable "konga_image_tag" {
  description = "Konga Docker image tag"
  type        = string
  default     = "latest"
}

variable "kong_task_count" {
  description = "Number of Kong ECS tasks to run"
  type        = number
  default     = 2
}

variable "nodejs_api_task_count" {
  description = "Number of Node.js API ECS tasks to run"
  type        = number
  default     = 2
}

variable "konga_task_count" {
  description = "Number of Konga ECS tasks to run"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
