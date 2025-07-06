variable "role_name" {
  type        = string
  description = "Name for the IAM role"
}

variable "policy_statements" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  description = "List of policy statements for least-privilege execution"
}
variable "attach_managed_policies" {
  type        = list(string)
  default     = []
  description = "List of managed AWS policy ARNs to attach (e.g. logging)"
}
