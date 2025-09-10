# nrsec-agent-tf-test

Repository to test SRX agent for remediations using Terraform to manage 10 S3 buckets across 3 modules.

## Architecture Overview

This Terraform configuration creates 10 S3 buckets distributed across 3 modules:

### Module 1: Storage (4 buckets)
- **data-lake**: Main data storage with versioning and encryption
- **backup-storage**: Backup storage with versioning and encryption
- **archive-storage**: Archive storage with encryption only
- **temp-storage**: Temporary storage with automatic cleanup (7 days)

### Module 2: Application (3 buckets)
- **web-assets**: Static web assets with CORS (private bucket)
- **user-uploads**: User file uploads with versioning and CORS
- **config-files**: Application configuration files with versioning

### Module 3: Analytics (3 buckets)
- **raw-logs**: Raw log data with lifecycle management
- **processed-data**: Processed analytics data with lifecycle management
- **reports**: Generated reports with versioning

## Prerequisites

1. **AWS CLI**: Install and configure AWS CLI
2. **Terraform**: Install Terraform (>= 1.0)
3. **AWS Credentials**: Configure AWS credentials with appropriate permissions

## Quick Start

1. Clone this repository
2. Configure your AWS credentials
3. Update `terraform.tfvars` with your desired values
4. Run the deployment commands

## Project Structure

```
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output definitions
├── terraform.tfvars       # Variable values
├── modules/
│   ├── storage/           # Storage module (4 buckets)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── application/       # Application module (3 buckets)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── analytics/         # Analytics module (3 buckets)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## Configuration

### Variables

- `aws_region`: AWS region for resources (default: us-east-1)
- `environment`: Environment name (default: dev)
- `project_name`: Project name for resource naming (default: nrsec-agent)

### Bucket Features

- **Encryption**: AES256 server-side encryption
- **Versioning**: Enabled for critical buckets
- **Public Access**: Completely blocked on ALL buckets
- **Bucket Policies**: Explicit deny policies for public access
- **Lifecycle**: Automatic transitions for analytics buckets
- **CORS**: Enabled for application buckets (private access only)
- **Security**: Multiple layers of protection against public exposure

## Outputs

After deployment, you'll get:
- Bucket names and ARNs for all modules
- Website endpoint for web-assets bucket
- Summary of all created resources
