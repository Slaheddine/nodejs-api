resource "aws_db_subnet_group" "kong" {
  name       = "${var.environment}-${var.project_name}-kong-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-subnet-group"
    }
  )
}

resource "aws_db_parameter_group" "kong" {
  name   = "${var.environment}-${var.project_name}-kong-pg"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-pg"
    }
  )
}

resource "aws_db_instance" "kong" {
  identifier             = "${var.environment}-${var.project_name}-kong-db"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  engine                 = "postgres"
  engine_version         = "13.7"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.kong.name
  vpc_security_group_ids = [var.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.kong.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  port                   = var.db_port
  
  # Enable deletion protection in production
  deletion_protection = var.environment == "prod" ? true : false
  
  # Enable automated backups
  backup_retention_period = var.environment == "prod" ? 7 : 1
  
  # Enable multi-AZ for production
  multi_az = var.environment == "prod" ? true : false
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-db"
    }
  )
}

# Create a secret for the database credentials
resource "aws_secretsmanager_secret" "kong_db" {
  name = "${var.environment}-${var.project_name}-kong-db-credentials"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-kong-db-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "kong_db" {
  secret_id = aws_secretsmanager_secret.kong_db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "postgres"
    host     = aws_db_instance.kong.address
    port     = var.db_port
    dbname   = var.db_name
  })
}
