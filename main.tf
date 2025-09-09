terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "nrsec-agent-tf-test"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Module 1: Storage buckets (4 S3 buckets)
module "storage_buckets" {
  source = "./modules/storage"

  environment  = var.environment
  project_name = var.project_name

  buckets = {
    "data-lake" = {
      versioning_enabled  = true
      encryption_enabled  = true
      public_access_block = true
    }
    "backup-storage" = {
      versioning_enabled  = true
      encryption_enabled  = true
      public_access_block = true
    }
    "archive-storage" = {
      versioning_enabled  = false
      encryption_enabled  = true
      public_access_block = true
    }
    "temp-storage" = {
      versioning_enabled  = false
      encryption_enabled  = false
      public_access_block = true
    }
  }
}

# Module 2: Application buckets (3 S3 buckets)
module "application_buckets" {
  source = "./modules/application"

  environment  = var.environment
  project_name = var.project_name

  buckets = {
    "web-assets" = {
      versioning_enabled  = false
      encryption_enabled  = true
      public_access_block = true
      cors_enabled        = true
    }
    "user-uploads" = {
      versioning_enabled  = true
      encryption_enabled  = true
      public_access_block = true
      cors_enabled        = true
    }
    "config-files" = {
      versioning_enabled  = true
      encryption_enabled  = true
      public_access_block = true
      cors_enabled        = false
    }
  }
}

# Module 3: Analytics buckets (3 S3 buckets)
module "analytics_buckets" {
  source = "./modules/analytics"

  environment  = var.environment
  project_name = var.project_name

  buckets = {
    "raw-logs" = {
      versioning_enabled = false
      encryption_enabled = true
      lifecycle_enabled  = true
      transition_days    = 30
    }
    "processed-data" = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_enabled  = true
      transition_days    = 90
    }
    "reports" = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_enabled  = false
      transition_days    = 0
    }
  }
}
