resource "aws_s3_bucket" "storage_buckets" {
  for_each = var.buckets

  bucket = "${var.project_name}-${var.environment}-storage-${each.key}"

  tags = {
    Name          = "${var.project_name}-${var.environment}-storage-${each.key}"
    Type          = "Storage"
    BucketPurpose = each.key
  }
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  for_each = { for k, v in var.buckets : k => v if v.versioning_enabled }

  bucket = aws_s3_bucket.storage_buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_encryption" {
  for_each = { for k, v in var.buckets : k => v if v.encryption_enabled }

  bucket = aws_s3_bucket.storage_buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "storage_pab" {
  for_each = { for k, v in var.buckets : k => v if v.public_access_block }

  bucket = aws_s3_bucket.storage_buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration for temp storage
resource "aws_s3_bucket_lifecycle_configuration" "temp_storage_lifecycle" {
  count = contains(keys(var.buckets), "temp-storage") ? 1 : 0

  bucket = aws_s3_bucket.storage_buckets["temp-storage"].id

  rule {
    id     = "temp_cleanup"
    status = "Enabled"

    # Add filter to specify which objects the rule applies to
    filter {
      prefix = ""
    }

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# Explicit bucket policy to deny all public access
resource "aws_s3_bucket_policy" "storage_deny_public" {
  for_each = var.buckets

  bucket = aws_s3_bucket.storage_buckets[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.storage_buckets[each.key].arn,
          "${aws_s3_bucket.storage_buckets[each.key].arn}/*"
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
