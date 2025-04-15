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

variable "rds_security_group_id" {
  description = "The ID of the security group for RDS"
  type        = string
}

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

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
