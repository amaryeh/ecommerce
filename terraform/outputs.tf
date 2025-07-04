output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.artifacts.bucket
}
output "db_endpoint" {
  value = aws_db_instance.ecommerce.endpoint
}
# output "db_read_replica_endpoint" {
#   value = aws_db_instance.ecommerce_replica.endpoint
# }

