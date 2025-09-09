# Storage Module Outputs
output "storage_bucket_names" {
  description = "Names of all storage buckets"
  value       = module.storage_buckets.bucket_names
}

output "storage_bucket_arns" {
  description = "ARNs of all storage buckets"
  value       = module.storage_buckets.bucket_arns
}

# Application Module Outputs
output "application_bucket_names" {
  description = "Names of all application buckets"
  value       = module.application_buckets.bucket_names
}

output "application_bucket_arns" {
  description = "ARNs of all application buckets"
  value       = module.application_buckets.bucket_arns
}

# Analytics Module Outputs
output "analytics_bucket_names" {
  description = "Names of all analytics buckets"
  value       = module.analytics_buckets.bucket_names
}

output "analytics_bucket_arns" {
  description = "ARNs of all analytics buckets"
  value       = module.analytics_buckets.bucket_arns
}

# Summary Output
output "all_bucket_summary" {
  description = "Summary of all created buckets"
  value = {
    total_buckets       = 10
    storage_buckets     = length(module.storage_buckets.bucket_names)
    application_buckets = length(module.application_buckets.bucket_names)
    analytics_buckets   = length(module.analytics_buckets.bucket_names)
  }
}
