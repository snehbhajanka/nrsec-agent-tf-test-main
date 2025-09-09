output "bucket_names" {
  description = "Names of all analytics buckets"
  value       = { for k, v in aws_s3_bucket.analytics_buckets : k => v.bucket }
}

output "bucket_arns" {
  description = "ARNs of all analytics buckets"
  value       = { for k, v in aws_s3_bucket.analytics_buckets : k => v.arn }
}

output "bucket_domains" {
  description = "Domain names of all analytics buckets"
  value       = { for k, v in aws_s3_bucket.analytics_buckets : k => v.bucket_domain_name }
}
