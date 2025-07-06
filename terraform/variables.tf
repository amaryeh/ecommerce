variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  default     = "default"
}
variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda package"
  type        = string
}

variable "s3_key" {
  description = "S3 key (object path) to the Lambda ZIP file"
  type        = string
  default     = null

}
