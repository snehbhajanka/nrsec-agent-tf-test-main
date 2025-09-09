output "bucket_names" {
  description = "Names of all storage buckets"
  value       = { for k, v in aws_s3_bucket.storage_buckets : k => v.bucket }
}

output "bucket_arns" {
  description = "ARNs of all storage buckets"
  value       = { for k, v in aws_s3_bucket.storage_buckets : k => v.arn }
}

output "bucket_domains" {
  description = "Domain names of all storage buckets"
  value       = { for k, v in aws_s3_bucket.storage_buckets : k => v.bucket_domain_name }
}
