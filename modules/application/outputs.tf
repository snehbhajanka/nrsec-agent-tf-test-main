output "bucket_names" {
  description = "Names of all application buckets"
  value       = { for k, v in aws_s3_bucket.application_buckets : k => v.bucket }
}

output "bucket_arns" {
  description = "ARNs of all application buckets"
  value       = { for k, v in aws_s3_bucket.application_buckets : k => v.arn }
}

output "bucket_domains" {
  description = "Domain names of all application buckets"
  value       = { for k, v in aws_s3_bucket.application_buckets : k => v.bucket_domain_name }
}

# Note: Website endpoint removed since all buckets are configured as private
# output "web_assets_website_endpoint" {
#   description = "Website endpoint for web-assets bucket"
#   value       = length(aws_s3_bucket_website_configuration.web_assets_website) > 0 ? aws_s3_bucket_website_configuration.web_assets_website[0].website_endpoint : null
# }
