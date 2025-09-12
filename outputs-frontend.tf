output "frontend_bucket_name" {
  description = "S3 bucket name for the frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "S3 bucket ARN for the frontend"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "CloudFront distribution id"
  value       = aws_cloudfront_distribution.frontend.id
}

output "frontend_aliases" {
  description = "Configured aliases for the distribution"
  value       = aws_cloudfront_distribution.frontend.aliases
}
