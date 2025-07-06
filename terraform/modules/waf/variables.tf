variable "name" {
  type        = string
  description = "Name of the Web ACL"
}

variable "scope" {
  type        = string
  default     = "REGIONAL"
  description = "Use REGIONAL for API Gateway, CLOUDFRONT for CDN"
}

variable "resource_arn" {
  type        = string
  description = "ARN of the resource to associate with this Web ACL"
}
