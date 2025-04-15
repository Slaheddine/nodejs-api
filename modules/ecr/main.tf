resource "aws_ecr_repository" "kong" {
  name                 = "${var.environment}-${var.project_name}-kong"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-ecr"
    }
  )
}

resource "aws_ecr_repository" "nodejs_api" {
  name                 = "${var.environment}-${var.project_name}-nodejs-api"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nodejs-api-ecr"
    }
  )
}

resource "aws_ecr_repository" "konga" {
  name                 = "${var.environment}-${var.project_name}-konga"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-konga-ecr"
    }
  )
}

# ECR Lifecycle Policy for Kong
resource "aws_ecr_lifecycle_policy" "kong" {
  repository = aws_ecr_repository.kong.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Node.js API
resource "aws_ecr_lifecycle_policy" "nodejs_api" {
  repository = aws_ecr_repository.nodejs_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Konga
resource "aws_ecr_lifecycle_policy" "konga" {
  repository = aws_ecr_repository.konga.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy for all repositories
resource "aws_ecr_repository_policy" "all_repos" {
  for_each   = toset([aws_ecr_repository.kong.name, aws_ecr_repository.nodejs_api.name, aws_ecr_repository.konga.name])
  repository = each.key

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromECS"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
