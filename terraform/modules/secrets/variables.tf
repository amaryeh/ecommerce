variable "name" {
  type        = string
  description = "Name of the secret"
}

variable "description" {
  type        = string
  default     = ""
  description = "Secret description"
}

variable "secret_string" {
  type        = string
  description = "JSON string to store as secret"
}
