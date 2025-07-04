variable "function_name" {}
variable "lambda_role_arn" {}
variable "handler" {}
variable "runtime" {
  default = "python3.9"
}
variable "zip_path" {
  description = "Path to Lambda .zip file"
}
variable "timeout" {
  default = 10
}
variable "environment_variables" {
  type    = map(string)
  default = {}
}
