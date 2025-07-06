output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "security_group_id" {
  value = aws_security_group.this.id
}
