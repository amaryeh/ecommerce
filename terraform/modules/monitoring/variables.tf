# modules/monitoring/variables.tf

variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance ID"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "How long to keep Lambda logs"
  type        = number
  default     = 7
}

variable "lambda_error_threshold" {
  description = "Number of errors to trigger Lambda alarm"
  type        = number
  default     = 1
}

variable "rds_cpu_threshold" {
  description = "CPU utilization threshold (%) to trigger RDS alarm"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of ARNs (like SNS topics) to notify"
  type        = list(string)
  default     = []
}

variable "enable_rds_monitoring" {
  description = "Whether to include RDS monitoring"
  type        = bool
  default     = false
}
