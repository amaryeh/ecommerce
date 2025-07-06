variable "name" {
  type        = string
  description = "Base name for the frontend bucket"
}

variable "suffix" {
  type        = string
  description = "Random suffix to make bucket name unique"
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "tags" {
  type    = map(string)
  default = {}
}
