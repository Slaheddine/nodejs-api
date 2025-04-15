output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.kong.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.kong.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.kong.endpoint
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.kong.port
}

output "db_name" {
  description = "The name of the database"
  value       = var.db_name
}

output "db_username" {
  description = "The username for the database"
  value       = var.db_username
}

output "db_secret_arn" {
  description = "The ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.kong_db.arn
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.kong.name
}
