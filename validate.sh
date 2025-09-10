#!/bin/bash

# Terraform Configuration Validation Script
# This script validates the Terraform configuration without requiring AWS credentials

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Starting Terraform configuration validation..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

print_success "Terraform is installed: $(terraform version --short)"

# Check if terraform.tfvars exists, if not suggest using the example
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. You can copy terraform.tfvars.example to terraform.tfvars and customize it."
    if [ -f "terraform.tfvars.example" ]; then
        print_status "Found terraform.tfvars.example - you can use: cp terraform.tfvars.example terraform.tfvars"
    fi
fi

# Format check
print_status "Checking Terraform format..."
if terraform fmt -check -recursive; then
    print_success "Terraform files are properly formatted"
else
    print_warning "Some files need formatting. Run 'terraform fmt -recursive' to fix."
fi

# Initialize Terraform (this will download providers but not connect to AWS)
print_status "Initializing Terraform..."
terraform init -backend=false

# Validate configuration
print_status "Validating Terraform configuration..."
if terraform validate; then
    print_success "Terraform configuration is valid!"
else
    print_error "Terraform configuration validation failed!"
    exit 1
fi

# Check for potential issues
print_status "Running additional checks..."

# Check if all required files exist
required_files=("main.tf" "variables.tf" "outputs.tf")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found required file: $file"
    else
        print_error "Missing required file: $file"
        exit 1
    fi
done

# Check module structure
print_status "Checking module structure..."
modules=("storage" "application" "analytics")
for module in "${modules[@]}"; do
    if [ -d "modules/$module" ]; then
        print_success "Found module: $module"
        # Check if module has required files
        for file in main.tf variables.tf outputs.tf; do
            if [ -f "modules/$module/$file" ]; then
                print_success "  - Found $file in $module module"
            else
                print_error "  - Missing $file in $module module"
                exit 1
            fi
        done
    else
        print_error "Missing module directory: modules/$module"
        exit 1
    fi
done

print_success "All validation checks passed!"
print_status "Configuration is ready for deployment."
print_status "To deploy: ensure AWS credentials are configured and run './deploy.sh apply'"