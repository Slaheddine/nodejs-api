output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "rds_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "kong_repository_url" {
  description = "The URL of the Kong ECR repository"
  value       = module.ecr.kong_repository_url
}

output "nodejs_api_repository_url" {
  description = "The URL of the Node.js API ECR repository"
  value       = module.ecr.nodejs_api_repository_url
}

output "konga_repository_url" {
  description = "The URL of the Konga ECR repository"
  value       = module.ecr.konga_repository_url
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito user pool"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "The ID of the Cognito user pool client"
  value       = module.cognito.client_id
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "kong_service_name" {
  description = "The name of the Kong ECS service"
  value       = module.kong.service_name
}

output "nodejs_api_service_name" {
  description = "The name of the Node.js API ECS service"
  value       = module.nodejs_api.service_name
}

output "konga_service_name" {
  description = "The name of the Konga ECS service"
  value       = module.konga.service_name
}

output "internal_alb_dns_name" {
  description = "The DNS name of the internal ALB"
  value       = module.alb.alb_dns_name
}

output "kong_container_port" {
  description = "The port of the Kong container"
  value       = module.kong.container_port
}

output "nodejs_api_container_port" {
  description = "The port of the Node.js API container"
  value       = module.nodejs_api.container_port
}

output "konga_container_port" {
  description = "The port of the Konga container"
  value       = module.konga.container_port
}

output "kong_admin_port" {
  description = "The admin port of the Kong container"
  value       = module.kong.admin_port
}
