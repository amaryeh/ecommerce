resource "aws_s3_bucket" "this" {
  bucket        = "${var.name}-${var.suffix}"
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
