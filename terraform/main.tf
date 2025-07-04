resource "aws_s3_bucket" "artifacts" {
  bucket = "ecommerce-artifacts-local"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

module "lambda_api" {
  source          = "./modules/lambda"
  function_name   = "product-api"
  lambda_role_arn = aws_iam_role.lambda_exec_role.arn
  handler         = "handler.handler"
  runtime         = "python3.9"
  zip_path        = "${path.module}/../build/product-api.zip"
  timeout         = 10
  environment_variables = {
    SECRET_ID       = "ecommerce-db-credentials"
    LOCALSTACK_HOST = "host.docker.internal"
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "ecommerce-api"
}
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "get_hello" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_api.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}

resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "ecommerce-db-credentials"
  description = "Mock RDS credentials for local dev"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "local_user"
    password = "local_pass_123"
    host     = "localhost"
    port     = 5432
    dbname   = "ecommerce_db"
  })
}
module "network" {
  source               = "./modules/network"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

resource "aws_db_subnet_group" "rds" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name = "ecommerce-db-subnets"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow DB access from Lambda"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "Allow Lambda to connect to Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Use a security group ref if Lambda is in the same VPC, or a CIDR block in LocalStack
    cidr_blocks = ["0.0.0.0/0"] # Replace with Lambda SG or bastion IP in real AWS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "ecommerce" {
  identifier        = "ecommerce-db"
  engine            = "postgres"
  multi_az          = true
  engine_version    = "15.3"
  instance_class    = "db.t3.medium"
  allocated_storage = 20
  username          = "admin"
  password          = "supersecurepassword"
  # ✅ Enable encryption at rest
  storage_encrypted      = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

# variable "enable_read_replica" {
#   type    = bool
#   default = false
# }
# resource "aws_db_instance" "ecommerce_replica" {
#   identifier             = "ecommerce-read-replica"
#   instance_class         = "db.t3.medium"
#   engine                 = aws_db_instance.ecommerce.engine
#   publicly_accessible    = false
#   replicate_source_db    = aws_db_instance.ecommerce.arn
#   skip_final_snapshot    = true
#   db_subnet_group_name   = aws_db_subnet_group.rds.name
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   depends_on             = [aws_db_instance.ecommerce]

#   tags = {
#     Role = "read-replica"
#   }
# }
resource "aws_s3_bucket" "frontend" {
  bucket = "ecommerce-frontend-${random_id.suffix.hex}"
  # acl    = "private" # will be accessed via CloudFront

  tags = {
    Environment = "dev"
    Service     = "frontend"
  }
}
resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.frontend]
}

resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ecommerce CloudFront"
}
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
      },
      Action   = ["s3:GetObject"],
      Resource = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}
resource "aws_cloudfront_distribution" "frontend_cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "dev"
    Service     = "frontend"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_encryption" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

module "monitoring" {
  source = "./modules/monitoring"
  providers = {
    aws = aws
  }
  lambda_function_name  = module.lambda_api.function_name
  db_instance_id        = aws_db_instance.ecommerce.id
  enable_rds_monitoring = true
  # alarm_actions            = [aws_sns_topic.alerts.arn]
  alarm_actions      = []
  log_retention_days = 14
}

module "alerts" {
  source              = "./modules/sns"
  topic_name          = "ecommerce-alerts"
  email_subscriptions = ["ops@example.com"] # use test emails or leave empty in LocalStack
}
module "dashboard" {
  source               = "./modules/dashboard"
  name                 = "ecommerce-dashboard"
  lambda_function_name = module.lambda_api.function_name
  db_instance_id       = aws_db_instance.ecommerce.id
}
