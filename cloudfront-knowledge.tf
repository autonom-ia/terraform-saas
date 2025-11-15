data "aws_caller_identity" "current" {}

# CloudFront OAC for S3
resource "aws_cloudfront_origin_access_control" "kb_oac" {
  name                              = "autonomia-kb-oac"
  description                       = "OAC for Knowledge Base S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution to serve the knowledge bucket
resource "aws_cloudfront_distribution" "kb_cdn" {
  enabled             = true
  comment             = "Autonomia Knowledge Base CDN"
  aliases             = ["kb-docs.autonomia.site"]

  origin {
    domain_name              = aws_s3_bucket.knowledge.bucket_regional_domain_name
    origin_id                = "s3-knowledge-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.kb_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-knowledge-origin"

    viewer_protocol_policy = "redirect-to-https"

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/cee74474-da0c-4aba-b9f7-3759e4eddd7e"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }
}

# Bucket policy to allow CloudFront (via OAC) to read objects
resource "aws_s3_bucket_policy" "knowledge_cf_policy" {
  bucket = aws_s3_bucket.knowledge.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowCloudFrontServicePrincipalReadOnly",
        Effect   = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.knowledge.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.kb_cdn.arn
          }
        }
      }
    ]
  })
}

# Optional: SSM parameters to be consumed by serverless API for public base URL
resource "aws_ssm_parameter" "knowledge_bucket_name" {
  name        = "/autonomia/${var.env}/knowledge/bucket"
  description = "Knowledge bucket name"
  type        = "String"
  value       = aws_s3_bucket.knowledge.bucket
  overwrite   = true
}

resource "aws_ssm_parameter" "knowledge_public_base" {
  name        = "/autonomia/${var.env}/knowledge/public-base"
  description = "Public base URL served by CloudFront for Knowledge documents"
  type        = "String"
  value       = "https://kb-docs.autonomia.site"
  overwrite   = true
}

output "knowledge_cdn_domain" {
  description = "CloudFront domain for Knowledge documents"
  value       = aws_cloudfront_distribution.kb_cdn.domain_name
}
