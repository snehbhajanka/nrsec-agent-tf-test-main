# AWS S3 Deployment Checklist

## Pre-Deployment Checklist

### AWS Account Setup
- [ ] Create AWS account at https://aws.amazon.com
- [ ] Verify email and complete account setup
- [ ] Add payment method (credit card)
- [ ] Access AWS Management Console

### IAM User Setup
- [ ] Go to IAM service in AWS Console
- [ ] Create new user: `terraform-user`
- [ ] Attach policy: `AmazonS3FullAccess`
- [ ] Create access keys
- [ ] Save Access Key ID and Secret Access Key securely

### Local Environment Setup
- [ ] Install Homebrew (if not installed)
- [ ] Install AWS CLI: `brew install awscli`
- [ ] Install Terraform: `brew install hashicorp/tap/terraform`
- [ ] Configure AWS CLI: `aws configure`
- [ ] Test AWS connection: `aws sts get-caller-identity`

## Deployment Checklist

### Quick Setup (Automated)
- [ ] Navigate to project directory
- [ ] Run automated setup: `./setup.sh`
- [ ] Follow prompts for configuration
- [ ] Confirm deployment when prompted

### Manual Setup (Step by Step)
- [ ] Navigate to project directory: `cd /Users/csuvarnakanti/Documents/Learning/nrsec-agent-tf-test`
- [ ] Review settings in `terraform.tfvars`
- [ ] Initialize Terraform: `./deploy.sh init`
- [ ] Validate configuration: `./deploy.sh validate`
- [ ] Create deployment plan: `./deploy.sh plan`
- [ ] Review plan output carefully
- [ ] Apply configuration: `./deploy.sh apply`
- [ ] Verify outputs: `./deploy.sh output`

## Post-Deployment Verification

### AWS Console Verification
- [ ] Login to AWS Console
- [ ] Navigate to S3 service
- [ ] Verify 10 buckets are created:
  - [ ] Storage buckets (4): data-lake, backup-storage, archive-storage, temp-storage
  - [ ] Application buckets (3): web-assets, user-uploads, config-files  
  - [ ] Analytics buckets (3): raw-logs, processed-data, reports

### CLI Verification
- [ ] List buckets: `aws s3 ls`
- [ ] Check Terraform outputs: `./deploy.sh output`
- [ ] Test file upload to one bucket
- [ ] Verify bucket configurations (encryption, versioning, etc.)

## Testing Checklist

### Basic Functionality Tests
- [ ] Upload test file: `echo "test" > test.txt && aws s3 cp test.txt s3://[bucket-name]/`
- [ ] List bucket contents: `aws s3 ls s3://[bucket-name]/`
- [ ] Download test file: `aws s3 cp s3://[bucket-name]/test.txt ./downloaded-test.txt`
- [ ] Delete test file: `aws s3 rm s3://[bucket-name]/test.txt`

### Configuration Tests
- [ ] Verify encryption is enabled on appropriate buckets
- [ ] Check versioning is enabled on specified buckets
- [ ] Confirm public access is blocked
- [ ] Test CORS configuration on application buckets
- [ ] Verify lifecycle policies on analytics buckets

## Cleanup Checklist (When Done)

### Resource Cleanup
- [ ] Empty all buckets (if they contain objects)
- [ ] Run: `./deploy.sh destroy`
- [ ] Confirm all buckets are deleted in AWS Console
- [ ] Remove local Terraform state: `rm -rf .terraform .terraform.lock.hcl terraform.tfstate*`

### Cost Management
- [ ] Check AWS billing dashboard
- [ ] Verify no unexpected charges
- [ ] Consider deleting IAM user if no longer needed

## Troubleshooting Checklist

### Common Issues
- [ ] Bucket name conflicts (S3 names must be globally unique)
- [ ] AWS credentials not configured properly
- [ ] Insufficient IAM permissions
- [ ] Region mismatch between AWS CLI and Terraform
- [ ] Terraform state corruption

### Debug Commands
- [ ] Check AWS identity: `aws sts get-caller-identity`
- [ ] Verify AWS CLI config: `aws configure list`
- [ ] Enable Terraform debug: `export TF_LOG=DEBUG`
- [ ] Check Terraform state: `terraform show`

## Quick Reference Commands

```bash
# Setup
./setup.sh                    # Automated setup
./deploy.sh help              # Show deployment options

# Deployment
./deploy.sh init              # Initialize Terraform
./deploy.sh plan              # Create deployment plan
./deploy.sh apply             # Deploy infrastructure
./deploy.sh deploy            # Full deployment (init + plan + apply)

# Management
./deploy.sh output            # Show created resources
aws s3 ls                     # List all S3 buckets
./deploy.sh destroy           # Delete all resources

# Testing
aws s3 cp file.txt s3://bucket-name/    # Upload file
aws s3 ls s3://bucket-name/             # List bucket contents
```

---

**Note**: This checklist covers deployment of **10 S3 buckets** (not 9) across 3 modules as designed in the Terraform configuration.
