variable "name" {
  type        = string
  description = "Name of the API Gateway REST API"
}

variable "stage_name" {
  type        = string
  default     = "dev"
  description = "Stage name for the API Gateway"
}

variable "path_part" {
  type        = string
  default     = "hello"
  description = "Path segment of the resource"
}

variable "http_method" {
  type        = string
  default     = "GET"
  description = "HTTP method for the API endpoint"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda function invoke ARN for integration"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name for permission attachment"
}

variable "region" {
  type        = string
  description = "AWS region where the API Gateway is deployed"
  default     = "us-east-1"

}
