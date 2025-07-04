variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "ecommerce-alerts"
}

variable "email_subscriptions" {
  description = "List of email addresses for SNS topic"
  type        = list(string)
  default     = []
}
