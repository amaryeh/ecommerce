variable "name" {
  type        = string
  description = "Base name for the S3 artifacts bucket"
}

variable "suffix" {
  type        = string
  description = "Random ID to ensure uniqueness"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Allow auto-delete of non-empty buckets (dev only)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
