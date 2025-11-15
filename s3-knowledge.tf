# S3 bucket for Knowledge Base documents
resource "aws_s3_bucket" "knowledge" {
  bucket        = var.knowledge_bucket_name
  force_destroy = false
  tags = {
    Project = "autonomia"
    Purpose = "knowledge-docs"
    Env     = var.env
  }
}

resource "aws_s3_bucket_versioning" "knowledge" {
  bucket = aws_s3_bucket.knowledge.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge" {
  bucket = aws_s3_bucket.knowledge.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Optional CORS: allow GET/HEAD from portal if accessing S3 directly from browser
resource "aws_s3_bucket_cors_configuration" "knowledge" {
  bucket = aws_s3_bucket.knowledge.id
  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.portal_allowed_origins
    allowed_headers = ["*"]
    max_age_seconds = 3600
  }
}

# Public access configuration (temporary, until we move to CloudFront or presigned URLs)
resource "aws_s3_bucket_public_access_block" "knowledge" {
  bucket                  = aws_s3_bucket.knowledge.id
  block_public_acls       = !var.knowledge_bucket_enable_public
  block_public_policy     = !var.knowledge_bucket_enable_public
  ignore_public_acls      = !var.knowledge_bucket_enable_public
  restrict_public_buckets = !var.knowledge_bucket_enable_public
}

resource "aws_s3_bucket_policy" "knowledge_public_get" {
  count  = var.knowledge_bucket_enable_public ? 1 : 0
  bucket = aws_s3_bucket.knowledge.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.knowledge.arn}/*"
      }
    ]
  })
}
