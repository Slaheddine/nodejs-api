resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.project_name}-alb-sg"
  description = "Security group for internal ALB"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from within VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow HTTP traffic from within VPC"
  }

  # Allow HTTPS traffic from within VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow HTTPS traffic from within VPC"
  }

  # Allow outbound traffic to ECS tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow all outbound traffic within VPC"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-alb-sg"
    }
  )
}

# Internal ALB
resource "aws_lb" "internal" {
  name               = "${var.environment}-${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-internal-alb"
    }
  )
}

# Target group for Kong
resource "aws_lb_target_group" "kong" {
  name        = "${var.environment}-${var.project_name}-kong-tg"
  port        = var.kong_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/status"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-tg"
    }
  )
}

# Target group for Konga
resource "aws_lb_target_group" "konga" {
  name        = "${var.environment}-${var.project_name}-konga-tg"
  port        = var.konga_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-konga-tg"
    }
  )
}

# Listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-http-listener"
    }
  )
}

# Listener rule for Konga
resource "aws_lb_listener_rule" "konga" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.konga.arn
  }

  condition {
    path_pattern {
      values = ["/konga*"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-konga-listener-rule"
    }
  )
}

# Register Kong service with target group
resource "aws_lb_target_group_attachment" "kong" {
  count            = 2  # Assuming 2 Kong tasks
  target_group_arn = aws_lb_target_group.kong.arn
  target_id        = "PLACEHOLDER_KONG_TASK_IP_${count.index}"  # This will be replaced in the main module
  port             = var.kong_container_port
  
  # This is a placeholder and will be handled differently in the actual implementation
  # since we need to get the actual task IPs dynamically
  lifecycle {
    ignore_changes = [target_id]
  }
}

# Register Konga service with target group
resource "aws_lb_target_group_attachment" "konga" {
  count            = 1  # Assuming 1 Konga task
  target_group_arn = aws_lb_target_group.konga.arn
  target_id        = "PLACEHOLDER_KONGA_TASK_IP"  # This will be replaced in the main module
  port             = var.konga_container_port
  
  # This is a placeholder and will be handled differently in the actual implementation
  lifecycle {
    ignore_changes = [target_id]
  }
}
