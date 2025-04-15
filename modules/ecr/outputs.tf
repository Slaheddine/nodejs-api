output "kong_repository_url" {
  description = "The URL of the Kong ECR repository"
  value       = aws_ecr_repository.kong.repository_url
}

output "kong_repository_name" {
  description = "The name of the Kong ECR repository"
  value       = aws_ecr_repository.kong.name
}

output "nodejs_api_repository_url" {
  description = "The URL of the Node.js API ECR repository"
  value       = aws_ecr_repository.nodejs_api.repository_url
}

output "nodejs_api_repository_name" {
  description = "The name of the Node.js API ECR repository"
  value       = aws_ecr_repository.nodejs_api.name
}

output "konga_repository_url" {
  description = "The URL of the Konga ECR repository"
  value       = aws_ecr_repository.konga.repository_url
}

output "konga_repository_name" {
  description = "The name of the Konga ECR repository"
  value       = aws_ecr_repository.konga.name
}

output "registry_id" {
  description = "The registry ID where the repositories were created"
  value       = aws_ecr_repository.kong.registry_id
}
