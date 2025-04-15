locals {
  konga_container_name = "${var.environment}-${var.project_name}-konga"
}

# ECS Task Definition for Konga
resource "aws_ecs_task_definition" "konga" {
  family                   = "${var.environment}-${var.project_name}-konga"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.konga_cpu
  memory                   = var.konga_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name         = local.konga_container_name
      image        = "${var.ecr_repository_url}:${var.konga_image_tag}"
      essential    = true
      portMappings = [
        {
          containerPort = var.konga_container_port
          hostPort      = var.konga_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = tostring(var.konga_container_port)
        },
        {
          name  = "DB_ADAPTER"
          value = "postgres"
        },
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_DATABASE"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "KONG_ADMIN_URL"
          value = var.kong_admin_url
        },
        {
          name  = "NODE_TLS_REJECT_UNAUTHORIZED"
          value = "0"  # Required for self-signed certificates in private VPC
        }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/${var.project_name}/konga-db-password"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group_name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "konga"
        }
      }
      # Add healthcheck to ensure container is ready
      healthCheck = {
        command     = ["CMD-SHELL", "wget -q -O - http://localhost:${var.konga_container_port}/api/health || exit 1"]
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
      Name = "${var.environment}-${var.project_name}-konga-task-definition"
    }
  )
}

# Store Konga DB password in SSM Parameter Store
resource "aws_ssm_parameter" "konga_db_password" {
  name        = "/${var.environment}/${var.project_name}/konga-db-password"
  description = "Database password for Konga"
  type        = "SecureString"
  value       = var.db_password

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-konga-db-password"
    }
  )
}

# ECS Service for Konga
resource "aws_ecs_service" "konga" {
  name                               = "${var.environment}-${var.project_name}-konga-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.konga.arn
  desired_count                      = var.konga_task_count
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
      Name = "${var.environment}-${var.project_name}-konga-service"
    }
  )
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
