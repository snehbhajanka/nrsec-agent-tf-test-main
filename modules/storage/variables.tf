variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "buckets" {
  description = "Map of bucket configurations"
  type = map(object({
    versioning_enabled  = bool
    encryption_enabled  = bool
    public_access_block = bool
  }))
}
