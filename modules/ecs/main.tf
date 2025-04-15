resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-cluster"
    }
  )
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name != null ? var.ecs_task_execution_role_name : "${var.environment}-${var.project_name}-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-task-execution-role"
    }
  )
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role_name != null ? var.ecs_task_role_name : "${var.environment}-${var.project_name}-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-task-role"
    }
  )
}

# Attach policies to the task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Enhanced policy for ECR access without internet
resource "aws_iam_policy" "ecr_access" {
  name        = "${var.environment}-${var.project_name}-ecr-access-policy"
  description = "Enhanced policy to allow ECS tasks to pull images from ECR without internet access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach ECR access policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

# Custom policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.environment}-${var.project_name}-cloudwatch-logs-policy"
  description = "Policy to allow ECS tasks to send logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach CloudWatch Logs policy to task role
resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_logs" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Add SSM access policy for task role
resource "aws_iam_policy" "ssm_access" {
  name        = "${var.environment}-${var.project_name}-ssm-access-policy"
  description = "Policy to allow ECS tasks to access SSM parameters"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/*"
      }
    ]
  })
}

# Attach SSM access policy to task role
resource "aws_iam_role_policy_attachment" "ecs_task_ssm_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

# Add Secrets Manager access policy for task role
resource "aws_iam_policy" "secretsmanager_access" {
  name        = "${var.environment}-${var.project_name}-secretsmanager-access-policy"
  description = "Policy to allow ECS tasks to access Secrets Manager secrets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:*"
      }
    ]
  })
}

# Attach Secrets Manager access policy to task role
resource "aws_iam_role_policy_attachment" "ecs_task_secretsmanager_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secretsmanager_access.arn
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
  
  # Allow inbound traffic for Kong proxy
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    description     = "Kong proxy port"
    cidr_blocks     = ["10.0.0.0/8"]
  }
  
  # Allow inbound traffic for Kong admin
  ingress {
    from_port       = 8001
    to_port         = 8001
    protocol        = "tcp"
    description     = "Kong admin port"
    cidr_blocks     = ["10.0.0.0/8"]
  }
  
  # Allow inbound traffic for Node.js API
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    description     = "Node.js API port"
    cidr_blocks     = ["10.0.0.0/8"]
  }
  
  # Allow inbound traffic for Konga
  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    description     = "Konga port"
    cidr_blocks     = ["10.0.0.0/8"]
  }
  
  # Allow all outbound traffic within VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow all outbound traffic within VPC"
  }
  
  # Allow outbound HTTPS traffic to VPC endpoints
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic to VPC endpoints"
  }
  
  # Allow outbound HTTP traffic to VPC endpoints (for ECR)
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic to VPC endpoints"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-ecs-tasks-sg"
    }
  )
}

# CloudWatch Log Group for Kong
resource "aws_cloudwatch_log_group" "kong" {
  name              = "/ecs/${var.environment}-${var.project_name}-kong"
  retention_in_days = 30
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-logs"
    }
  )
}

# CloudWatch Log Group for Node.js API
resource "aws_cloudwatch_log_group" "nodejs_api" {
  name              = "/ecs/${var.environment}-${var.project_name}-nodejs-api"
  retention_in_days = 30
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nodejs-api-logs"
    }
  )
}

# CloudWatch Log Group for Konga
resource "aws_cloudwatch_log_group" "konga" {
  name              = "/ecs/${var.environment}-${var.project_name}-konga"
  retention_in_days = 30
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-konga-logs"
    }
  )
}
