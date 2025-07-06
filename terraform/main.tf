
module "artifacts" {
  source = "./modules/artifacts"
  name   = "ecommerce-artifacts"
  suffix = random_id.suffix.hex
  tags = {
    Environment = "dev"
    Purpose     = "build-artifacts"
  }
}

module "db_secrets" {
  source      = "./modules/secrets"
  name        = "ecommerce-db-credentials"
  description = "Mock RDS credentials for local dev"
  secret_string = jsonencode({
    username = "local_user"
    password = "local_pass_123"
    host     = "localhost"
    port     = 5432
    dbname   = "ecommerce_db"
  })
}


module "lambda_iam" {
  source    = "./modules/iam"
  role_name = "lambda-api-role"

  policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
    }
  ]
}

module "lambda_api" {
  source           = "./modules/lambda"
  function_name    = "product-api"
  lambda_role_arn  = module.lambda_iam.role_arn
  handler          = "app.main.handler"
  runtime          = "python3.10"
  timeout          = 10
  s3_bucket        = module.artifacts.bucket_name
  s3_key           = "lambdas/product-api.zip"
  source_code_hash = var.source_code_hash # ✅ passed from CLI or tfvars  environment_variables = {
  environment_variables = {
    SECRET_ID           = "product-api-key"
    AWS_REGION          = "us-east-1"
    LOCALSTACK_ENDPOINT = "http://localstack:4566" # LocalStack endpoint
    DATABASE_URL        = "postgresql://admin:supersecurepassword@localhost.localstack.cloud:4510/test"
  }
}


module "apigw" {
  source               = "./modules/apigw"
  name                 = "ecommerce-api"
  stage_name           = "dev"
  path_part            = "{proxy+}"
  http_method          = "ANY"
  lambda_invoke_arn    = module.lambda_api.invoke_arn
  lambda_function_name = module.lambda_api.function_name
}

module "network" {
  source               = "./modules/network"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

module "rds" {
  source             = "./modules/rds"
  name               = "ecommerce-db"
  username           = "admin"
  password           = "supersecurepassword"
  private_subnet_ids = module.network.private_subnet_ids
  vpc_id             = module.network.vpc_id
  allowed_cidrs      = ["0.0.0.0/0"] # Dev use
}

module "frontend" {
  source = "./modules/frontend"
  name   = "ecommerce-frontend"
  suffix = random_id.suffix.hex
  tags = {
    Environment = "dev"
    Service     = "frontend"
  }
}


resource "random_id" "suffix" {
  byte_length = 4
}

module "monitoring" {
  source = "./modules/monitoring"
  providers = {
    aws = aws
  }
  lambda_function_name  = module.lambda_api.function_name
  db_instance_id        = module.rds.db_instance_id
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
  db_instance_id       = module.rds.db_instance_id
}
module "waf_api" {
  source       = "./modules/waf"
  name         = "ecommerce-api-waf"
  resource_arn = module.apigw.stage_arn
}
