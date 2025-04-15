terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.tags
  }
}

# VPC and networking resources
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
  project_name         = var.project_name
  tags                 = var.tags
}

# RDS PostgreSQL for Kong
module "rds" {
  source = "./modules/rds"
  
  environment          = var.environment
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_security_group_id = module.vpc.rds_security_group_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  tags                 = var.tags
}

# ECR repositories for all services
module "ecr" {
  source = "./modules/ecr"
  
  environment  = var.environment
  project_name = var.project_name
  tags         = var.tags
}

# Cognito resources for authentication
module "cognito" {
  source = "./modules/cognito"
  
  environment   = var.environment
  project_name  = var.project_name
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
  tags          = var.tags
}

# ECS cluster and resources
module "ecs" {
  source = "./modules/ecs"
  
  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = var.tags
}

# Kong API with PostgreSQL database
module "kong" {
  source = "./modules/kong"
  
  environment               = var.environment
  project_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  ecs_cluster_id            = module.ecs.cluster_id
  ecs_task_execution_role_arn = module.ecs.task_execution_role_arn
  ecs_task_role_arn         = module.ecs.task_role_arn
  ecs_tasks_security_group_id = module.ecs.ecs_tasks_security_group_id
  ecr_repository_url        = module.ecr.kong_repository_url
  cloudwatch_log_group_name = module.ecs.kong_cloudwatch_log_group_name
  kong_image_tag            = var.kong_image_tag
  kong_task_count           = var.kong_task_count
  
  # Database connection details
  db_host                   = module.rds.db_instance_address
  db_port                   = module.rds.db_instance_port
  db_name                   = module.rds.db_name
  db_username               = module.rds.db_username
  db_password               = var.db_password
  db_secret_arn             = module.rds.db_secret_arn
  
  tags                      = var.tags
}

# Node.js API with Cognito authentication
module "nodejs_api" {
  source = "./modules/nodejs-api"
  
  environment               = var.environment
  project_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  ecs_cluster_id            = module.ecs.cluster_id
  ecs_task_execution_role_arn = module.ecs.task_execution_role_arn
  ecs_task_role_arn         = module.ecs.task_role_arn
  ecs_tasks_security_group_id = module.ecs.ecs_tasks_security_group_id
  ecr_repository_url        = module.ecr.nodejs_api_repository_url
  cloudwatch_log_group_name = module.ecs.nodejs_api_cloudwatch_log_group_name
  nodejs_api_image_tag      = var.nodejs_api_image_tag
  nodejs_api_task_count     = var.nodejs_api_task_count
  
  # Cognito details
  cognito_user_pool_id      = module.cognito.user_pool_id
  cognito_client_id         = module.cognito.client_id
  cognito_client_secret     = module.cognito.client_secret
  
  tags                      = var.tags
}

# Konga admin UI for Kong
module "konga" {
  source = "./modules/konga"
  
  environment               = var.environment
  project_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  ecs_cluster_id            = module.ecs.cluster_id
  ecs_task_execution_role_arn = module.ecs.task_execution_role_arn
  ecs_task_role_arn         = module.ecs.task_role_arn
  ecs_tasks_security_group_id = module.ecs.ecs_tasks_security_group_id
  ecr_repository_url        = module.ecr.konga_repository_url
  cloudwatch_log_group_name = module.ecs.konga_cloudwatch_log_group_name
  konga_image_tag           = var.konga_image_tag
  konga_task_count          = var.konga_task_count
  
  # Kong admin URL (internal service discovery)
  kong_admin_url            = "http://${module.kong.service_name}.${var.environment}-${var.project_name}:8001"
  
  # Database connection details (using the same RDS instance as Kong)
  db_host                   = module.rds.db_instance_address
  db_port                   = module.rds.db_instance_port
  db_name                   = "konga"  # Different database name for Konga
  db_username               = module.rds.db_username
  db_password               = var.db_password
  
  tags                      = var.tags
}

# Internal ALB for exposing services
module "alb" {
  source = "./modules/alb"
  
  environment               = var.environment
  project_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  ecs_tasks_security_group_id = module.ecs.ecs_tasks_security_group_id
  
  # Kong service details
  kong_service_name         = module.kong.service_name
  kong_container_name       = module.kong.container_name
  kong_container_port       = module.kong.container_port
  
  # Node.js API service details
  nodejs_api_service_name   = module.nodejs_api.service_name
  nodejs_api_container_name = module.nodejs_api.container_name
  nodejs_api_container_port = module.nodejs_api.container_port
  
  # Konga service details
  konga_service_name        = module.konga.service_name
  konga_container_name      = module.konga.container_name
  konga_container_port      = module.konga.container_port
  
  tags                      = var.tags
}

# Configure Kong to manage the Node.js API
# This would typically be done through Kong's Admin API after deployment
# For Terraform, we can use a null_resource with local-exec provisioner
# or create a Lambda function to configure Kong
# For this example, we'll include instructions in the README.md on how to configure Kong manually
