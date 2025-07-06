output "bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}
