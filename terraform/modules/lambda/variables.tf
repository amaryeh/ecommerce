variable "function_name" {}
variable "lambda_role_arn" {
  type        = string
  description = "IAM role ARN for the Lambda function"
}
variable "handler" {}
variable "runtime" {
  default = "python3.9"
}
# variable "zip_path" {
#   type        = string
#   description = "Path to Lambda .zip file"
#   default     = null
# }
variable "timeout" {
  default = 10
}
variable "environment_variables" {
  type    = map(string)
  default = {}
}
variable "s3_bucket" {
  type        = string
  description = "S3 bucket where the Lambda ZIP file is stored"
  default     = null
}

variable "s3_key" {
  type        = string
  description = "S3 key (object path) to the Lambda ZIP"
  default     = null
}
variable "source_code_hash" {
  type = string
  #default     = null
  description = "Base64-encoded SHA256 hash of the deployment package"
}
