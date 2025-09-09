resource "aws_s3_bucket" "application_buckets" {
  for_each = var.buckets
  
  bucket = "${var.project_name}-${var.environment}-app-${each.key}"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-${each.key}"
    Type = "Application"
    BucketPurpose = each.key
  }
}

resource "aws_s3_bucket_versioning" "application_versioning" {
  for_each = { for k, v in var.buckets : k => v if v.versioning_enabled }
  
  bucket = aws_s3_bucket.application_buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "application_encryption" {
  for_each = { for k, v in var.buckets : k => v if v.encryption_enabled }
  
  bucket = aws_s3_bucket.application_buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "application_pab" {
  for_each = var.buckets
  
  bucket = aws_s3_bucket.application_buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "application_cors" {
  for_each = { for k, v in var.buckets : k => v if v.cors_enabled }
  
  bucket = aws_s3_bucket.application_buckets[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Explicit bucket policy to deny all public access
resource "aws_s3_bucket_policy" "application_deny_public" {
  for_each = var.buckets
  
  bucket = aws_s3_bucket.application_buckets[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.application_buckets[each.key].arn,
          "${aws_s3_bucket.application_buckets[each.key].arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalServiceName" = [
              "cloudfront.amazonaws.com",
              "logging.s3.amazonaws.com"
            ]
          }
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Note: Static website configuration removed to ensure bucket remains private
# If you need static website hosting, you would need to:
# 1. Set public_access_block = false for web-assets bucket
# 2. Add appropriate bucket policy for public read access
# 3. Uncomment the website configuration below
#
# resource "aws_s3_bucket_website_configuration" "web_assets_website" {
#   count = contains(keys(var.buckets), "web-assets") ? 1 : 0
#   
#   bucket = aws_s3_bucket.application_buckets["web-assets"].id
#
#   index_document {
#     suffix = "index.html"
#   }
#
#   error_document {
#     key = "error.html"
#   }
# }
