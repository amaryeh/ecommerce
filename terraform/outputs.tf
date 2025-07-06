output "artifacts_bucket_name" {
  description = "S3 bucket name"
  value       = module.artifacts.bucket_name
}
output "db_endpoint" {
  value = module.rds.db_instance_id
}
# output "db_read_replica_endpoint" {
#   value = aws_db_instance.ecommerce_replica.endpoint
# }
output "db_secret_id" {
  value = module.db_secrets.secret_id
}
output "apigw_stage_arn" {
  value = module.apigw.stage_arn
}

output "frontend_cdn_domain" {
  description = "CloudFront distribution domain name for the frontend"
  value       = module.frontend.cloudfront_domain_name
}
output "frontend_bucket_name" {
  description = "The S3 bucket backing the frontend"
  value       = module.frontend.bucket_name
}

output "frontend_cdn_id" {
  description = "CloudFront distribution ID"
  value       = module.frontend.distribution_id
}
