resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-subnets"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Allow DB access from Lambda"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.name
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.username
  password               = var.password
  storage_encrypted      = true
  multi_az               = var.multi_az
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
}
