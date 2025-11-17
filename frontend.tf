###############################
# Certificate resolution (ACM)
###############################
# Ensure we query ACM in us-east-1 (required for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# If certificate_arn is not provided, look up the most recent ISSUED cert
# matching the provided domain name (e.g., "*.autonomia.site") in us-east-1
data "aws_acm_certificate" "frontend" {
  provider    = aws.us_east_1
  domain      = var.acm_domain_name
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

locals {
  # Explicit ARN wins; otherwise use looked-up ACM cert ARN; fallback to empty
  frontend_certificate_arn = var.certificate_arn != "" ? var.certificate_arn : try(data.aws_acm_certificate.frontend.arn, "")
}

# S3 bucket for SPA assets (private, served via CloudFront OAC)
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CloudFront Origin Access Control (recommended over OAI)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-${var.environment}-frontend-oac"
  description                       = "OAC for ${var.frontend_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Function to rewrite URLs for static export with trailing slash
resource "aws_cloudfront_function" "url_rewrite" {
  name    = "${var.project}-${var.environment}-url-rewrite"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite URLs to support Next.js static export with trailingSlash"
  publish = true
  code    = <<-EOT
function handler(event) {
  var request = event.request;
  var uri = request.uri;
  
  // If URI ends with /, append index.html
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
  }
  // If URI has no extension and no trailing slash, add /index.html
  else if (!uri.includes('.')) {
    request.uri = uri + '/index.html';
  }
  
  return request;
}
EOT
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "${var.project}-${var.environment}-frontend"
  aliases             = var.frontend_domains
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-frontend-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # Attach CloudFront Function to rewrite URLs
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  # Removed custom_error_response - files should exist in S3 with static export

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.frontend_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = local.frontend_certificate_arn == ""
  }
}

# Allow CloudFront to read from S3 using OAC
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = [
          "s3:GetObject"
        ],
        Resource = ["${aws_s3_bucket.frontend.arn}/*"],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}
