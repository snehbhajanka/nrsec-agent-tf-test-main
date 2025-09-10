resource "aws_s3_bucket" "analytics_buckets" {
  for_each = var.buckets

  bucket = "${var.project_name}-${var.environment}-analytics-${each.key}"

  tags = {
    Name          = "${var.project_name}-${var.environment}-analytics-${each.key}"
    Type          = "Analytics"
    BucketPurpose = each.key
  }
}

resource "aws_s3_bucket_versioning" "analytics_versioning" {
  for_each = { for k, v in var.buckets : k => v if v.versioning_enabled }

  bucket = aws_s3_bucket.analytics_buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics_encryption" {
  for_each = { for k, v in var.buckets : k => v if v.encryption_enabled }

  bucket = aws_s3_bucket.analytics_buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "analytics_pab" {
  for_each = var.buckets

  bucket = aws_s3_bucket.analytics_buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "analytics_lifecycle" {
  for_each = { for k, v in var.buckets : k => v if v.lifecycle_enabled }

  bucket = aws_s3_bucket.analytics_buckets[each.key].id

  rule {
    id     = "${each.key}_lifecycle"
    status = "Enabled"

    transition {
      days          = each.value.transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = each.value.transition_days + 60
      storage_class = "GLACIER"
    }

    transition {
      days          = each.value.transition_days + 180
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "analytics_deny_public" {
  for_each = var.buckets

  bucket = aws_s3_bucket.analytics_buckets[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.analytics_buckets[each.key].arn,
          "${aws_s3_bucket.analytics_buckets[each.key].arn}/*"
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
