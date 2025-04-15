locals {
  kong_container_name = "${var.environment}-${var.project_name}-kong"
}

# ECS Task Definition for Kong
resource "aws_ecs_task_definition" "kong" {
  family                   = "${var.environment}-${var.project_name}-kong"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.kong_cpu
  memory                   = var.kong_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name         = local.kong_container_name
      image        = "${var.ecr_repository_url}:${var.kong_image_tag}"
      essential    = true
      portMappings = [
        {
          containerPort = var.kong_container_port
          hostPort      = var.kong_container_port
          protocol      = "tcp"
        },
        {
          containerPort = var.kong_admin_port
          hostPort      = var.kong_admin_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "KONG_DATABASE"
          value = "postgres"
        },
        {
          name  = "KONG_PG_HOST"
          value = var.db_host
        },
        {
          name  = "KONG_PG_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "KONG_PG_DATABASE"
          value = var.db_name
        },
        {
          name  = "KONG_PG_USER"
          value = var.db_username
        },
        {
          name  = "KONG_PG_PASSWORD"
          value = var.db_password
        },
        {
          name  = "KONG_PROXY_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_ADMIN_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_PROXY_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_LISTEN"
          value = "0.0.0.0:${var.kong_admin_port}"
        },
        {
          name  = "KONG_PROXY_LISTEN"
          value = "0.0.0.0:${var.kong_container_port}"
        }
      ]
      secrets = [
        {
          name      = "KONG_PG_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group_name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "kong"
        }
      }
      # Add healthcheck to ensure container is ready
      healthCheck = {
        command     = ["CMD-SHELL", "kong health"]
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
      Name = "${var.environment}-${var.project_name}-kong-task-definition"
    }
  )
}

# ECS Service for Kong
resource "aws_ecs_service" "kong" {
  name                               = "${var.environment}-${var.project_name}-kong-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.kong.arn
  desired_count                      = var.kong_task_count
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
      Name = "${var.environment}-${var.project_name}-kong-service"
    }
  )
}

# Auto Scaling for Kong service
resource "aws_appautoscaling_target" "kong" {
  max_capacity       = 4
  min_capacity       = var.kong_task_count
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.kong.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "kong_cpu" {
  name               = "${var.environment}-${var.project_name}-kong-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.kong.resource_id
  scalable_dimension = aws_appautoscaling_target.kong.scalable_dimension
  service_namespace  = aws_appautoscaling_target.kong.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
