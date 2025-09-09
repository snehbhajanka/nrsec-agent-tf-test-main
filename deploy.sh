#!/bin/bash

# AWS S3 Terraform Deployment Script
# This script helps deploy and manage the S3 infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized successfully!"
}

# Function to validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    terraform validate
    print_success "Terraform configuration is valid!"
}

# Function to plan Terraform deployment
plan_terraform() {
    print_status "Creating Terraform plan..."
    terraform plan -out=tfplan
    print_success "Terraform plan created successfully!"
    print_warning "Review the plan above before applying!"
}

# Function to apply Terraform configuration
apply_terraform() {
    print_status "Applying Terraform configuration..."
    if [ -f "tfplan" ]; then
        terraform apply tfplan
        rm -f tfplan
    else
        terraform apply -auto-approve
    fi
    print_success "Terraform applied successfully!"
}

# Function to destroy infrastructure
destroy_terraform() {
    print_warning "This will destroy all S3 buckets and related resources!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_status "Destroying Terraform infrastructure..."
        terraform destroy -auto-approve
        print_success "Infrastructure destroyed successfully!"
    else
        print_status "Destruction cancelled."
    fi
}

# Function to run validation tests
run_tests() {
    print_status "Running validation tests..."
    if [ -f "test-validation.sh" ]; then
        ./test-validation.sh
    else
        print_error "test-validation.sh not found!"
        exit 1
    fi
}

# Function to show outputs
show_outputs() {
    print_status "Showing Terraform outputs..."
    terraform output
}

# Function to show help
show_help() {
    echo "AWS S3 Terraform Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  init      Initialize Terraform"
    echo "  validate  Validate Terraform configuration"
    echo "  plan      Create Terraform plan"
    echo "  apply     Apply Terraform configuration"
    echo "  destroy   Destroy all infrastructure"
    echo "  output    Show Terraform outputs"
    echo "  test      Run validation tests"
    echo "  deploy    Run init, validate, plan, and apply in sequence"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy    # Full deployment"
    echo "  $0 plan      # Just show what will be created"
    echo "  $0 test      # Run validation tests"
    echo "  $0 output    # Show created resources"
}

# Main script logic
case "$1" in
    "init")
        check_prerequisites
        init_terraform
        ;;
    "validate")
        validate_terraform
        ;;
    "plan")
        check_prerequisites
        plan_terraform
        ;;
    "apply")
        check_prerequisites
        apply_terraform
        ;;
    "deploy")
        check_prerequisites
        init_terraform
        validate_terraform
        plan_terraform
        echo ""
        read -p "Do you want to apply this plan? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            apply_terraform
            show_outputs
        else
            print_status "Deployment cancelled."
        fi
        ;;
    "destroy")
        destroy_terraform
        ;;
    "output")
        show_outputs
        ;;
    "test")
        run_tests
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
