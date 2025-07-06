variable "name" {}
variable "username" {}
variable "password" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}
variable "allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "allocated_storage" {
  default = 20
}
variable "instance_class" {
  default = "db.t3.medium"
}
variable "multi_az" {
  default = true
}
