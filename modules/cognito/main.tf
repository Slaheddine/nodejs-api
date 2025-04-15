resource "aws_cognito_user_pool" "main" {
  name = "${var.environment}-${var.project_name}-user-pool"
  
  username_attributes      = ["email"]
  auto_verify_attributes   = ["email"]
  
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    
    string_attribute_constraints {
      min_length = 7
      max_length = 320
    }
  }
  
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-user-pool"
    }
  )
}

resource "aws_cognito_user_pool_client" "api_client" {
  name                         = "${var.environment}-${var.project_name}-api-client"
  user_pool_id                 = aws_cognito_user_pool.main.id
  
  generate_secret              = true
  refresh_token_validity       = 30
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
  
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true
  
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.environment}-${var.project_name}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Create a resource server for the API
resource "aws_cognito_resource_server" "api" {
  identifier = "https://api.${var.environment}-${var.project_name}.example.com"
  name       = "${var.environment}-${var.project_name}-api"
  
  user_pool_id = aws_cognito_user_pool.main.id
  
  scope {
    scope_name        = "read"
    scope_description = "Read access to API"
  }
  
  scope {
    scope_name        = "write"
    scope_description = "Write access to API"
  }
}
