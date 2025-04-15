locals {
  nodejs_api_container_name = "${var.environment}-${var.project_name}-nodejs-api"
}

# ECS Task Definition for Node.js API
resource "aws_ecs_task_definition" "nodejs_api" {
  family                   = "${var.environment}-${var.project_name}-nodejs-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.nodejs_api_cpu
  memory                   = var.nodejs_api_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name         = local.nodejs_api_container_name
      image        = "${var.ecr_repository_url}:${var.nodejs_api_image_tag}"
      essential    = true
      portMappings = [
        {
          containerPort = var.nodejs_api_container_port
          hostPort      = var.nodejs_api_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "PORT"
          value = tostring(var.nodejs_api_container_port)
        },
        {
          name  = "COGNITO_USER_POOL_ID"
          value = var.cognito_user_pool_id
        },
        {
          name  = "COGNITO_CLIENT_ID"
          value = var.cognito_client_id
        },
        {
          name  = "AWS_REGION"
          value = "eu-west-1"
        }
      ]
      secrets = [
        {
          name      = "COGNITO_CLIENT_SECRET"
          valueFrom = "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/${var.project_name}/cognito-client-secret"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group_name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "nodejs-api"
        }
      }
      # Add healthcheck to ensure container is ready
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.nodejs_api_container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  # Enable ECS Exec for debugging
  enable_execute_command = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nodejs-api-task-definition"
    }
  )
}

# Store Cognito client secret in SSM Parameter Store
resource "aws_ssm_parameter" "cognito_client_secret" {
  name        = "/${var.environment}/${var.project_name}/cognito-client-secret"
  description = "Cognito client secret for Node.js API"
  type        = "SecureString"
  value       = var.cognito_client_secret

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-cognito-client-secret"
    }
  )
}

# ECS Service for Node.js API
resource "aws_ecs_service" "nodejs_api" {
  name                               = "${var.environment}-${var.project_name}-nodejs-api-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.nodejs_api.arn
  desired_count                      = var.nodejs_api_task_count
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 120
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_tasks_security_group_id]
    assign_public_ip = false
  }
  
  # Enable ECS Exec for debugging
  enable_execute_command = true
  
  # Ignore changes to desired_count to allow autoscaling
  lifecycle {
    ignore_changes = [desired_count]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nodejs-api-service"
    }
  )
}

# Auto Scaling for Node.js API service
resource "aws_appautoscaling_target" "nodejs_api" {
  max_capacity       = 4
  min_capacity       = var.nodejs_api_task_count
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.nodejs_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "nodejs_api_cpu" {
  name               = "${var.environment}-${var.project_name}-nodejs-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.nodejs_api.resource_id
  scalable_dimension = aws_appautoscaling_target.nodejs_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.nodejs_api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
