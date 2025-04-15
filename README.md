# Kong API Platform with Node.js API and Konga Admin UI

This Terraform project deploys a complete API platform in AWS ECS with the following components:

1. **Kong API Gateway** - Configured with a PostgreSQL database for persistence
2. **Node.js API** - Secured with AWS Cognito authentication
3. **Konga Admin UI** - For managing Kong

All services run in a private VPC without internet access, using VPC endpoints for AWS service connectivity.

## Architecture

The infrastructure consists of:

- **VPC** with private and public subnets (no internet gateway)
- **RDS PostgreSQL** database for Kong
- **ECR repositories** for all service images
- **Cognito** user pool for API authentication
- **ECS cluster** running three services:
  - Kong API Gateway
  - Node.js API
  - Konga Admin UI
- **Internal ALB** for exposing services within the VPC

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or newer
- Docker for building and pushing images

## Getting Started

1. **Initialize Terraform**:
   ```
   terraform init
   ```

2. **Configure Variables**:
   Create a `terraform.tfvars` file with your specific values:
   ```
   aws_region = "eu-west-1"
   environment = "dev"
   project_name = "api-platform"
   vpc_cidr = "10.0.0.0/16"
   db_password = "YourSecurePassword"
   ```

3. **Build and Push Docker Images**:
   
   For Kong:
   ```bash
   aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com
   docker build -t <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-kong:latest -f Dockerfile.kong .
   docker push <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-kong:latest
   ```

   For Node.js API:
   ```bash
   # Build your Node.js API image
   cd app
   docker build -t <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-nodejs-api:latest .
   docker push <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-nodejs-api:latest
   ```

   For Konga:
   ```bash
   docker build -t <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-konga:latest -f Dockerfile.konga .
   docker push <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/dev-api-platform-konga:latest
   ```

4. **Apply Terraform Configuration**:
   ```
   terraform apply
   ```

## Configuring Kong to Manage the Node.js API

After deployment, you'll need to configure Kong to route traffic to your Node.js API. You can do this through the Konga admin UI or using the Kong Admin API:

1. **Access Konga UI**:
   Connect to the internal ALB at `http://<internal-alb-dns-name>/konga`

2. **Add Your API to Kong**:
   Create a new service pointing to your Node.js API:
   ```
   Service Name: nodejs-api
   URL: http://dev-api-platform-nodejs-api-service.dev-api-platform:3000
   ```

3. **Add a Route**:
   ```
   Paths: /api
   Methods: GET, POST
   ```

4. **Configure Cognito Plugin**:
   Add the Cognito plugin to the service to enable authentication.

## Node.js API Example

The Node.js API should include two example endpoints:

1. `/api/example1` - First example endpoint
2. `/api/example2` - Second example endpoint

Both endpoints are secured with Cognito authentication.

## Security Considerations

- All traffic stays within the VPC
- No internet access is provided to any service
- AWS services are accessed via VPC endpoints
- Database credentials are stored in AWS Secrets Manager
- Cognito provides secure authentication

## Troubleshooting

### ECR Image Pull Issues

If ECS tasks can't pull images from ECR:

1. Verify VPC endpoints are correctly configured
2. Check security group rules allow traffic between ECS tasks and VPC endpoints
3. Ensure the task execution role has proper permissions

### Database Connectivity

If Kong can't connect to the database:

1. Check security group rules allow traffic on port 5432
2. Verify database credentials in Secrets Manager
3. Ensure the RDS instance is in the same VPC as the ECS tasks

## Maintenance

- ECR repositories have lifecycle policies to keep only the last 10 images
- ECS services are configured with auto-scaling based on CPU utilization
- RDS has automated backups enabled
