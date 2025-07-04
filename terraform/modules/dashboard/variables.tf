variable "name" {
  type        = string
  description = "Name of the CloudWatch dashboard"
  default     = "ecommerce-dashboard"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function to display metrics for"
}

variable "db_instance_id" {
  type        = string
  description = "The identifier of the RDS instance to monitor"
}
