resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description
}

resource "aws_secretsmanager_secret_version" "version" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}
