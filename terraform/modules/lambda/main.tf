resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash
  environment {
    variables = var.environment_variables
  }
}
