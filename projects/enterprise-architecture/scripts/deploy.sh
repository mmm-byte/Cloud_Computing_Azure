#!/bin/bash

##########################################################################
# Azure Enterprise Architecture Deployment Script
# Purpose: Deploy infrastructure using Terraform with validation
# Usage: ./deploy.sh [environment] [action]
##########################################################################

set -e
set -u
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ENVIRONMENT="${1:-prod}"
ACTION="${2:-plan}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$SCRIPT_DIR/logs/deployment-$ENVIRONMENT-$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$SCRIPT_DIR/logs"

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "$timestamp [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { echo -e "${BLUE}[INFO]${NC} $@" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $@" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $@" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" | tee -a "$LOG_FILE"; }

# Validation functions
validate_environment() {
    case $ENVIRONMENT in
        dev|staging|prod)
            log_info "Environment: $ENVIRONMENT"
            ;;
        *)
            log_error "Invalid environment. Must be: dev, staging, or prod"
            exit 1
            ;;
    esac
}

validate_prerequisites() {
    log_info "Validating prerequisites..."

    local missing_tools=()

    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi

    if ! command -v az &> /dev/null; then
        missing_tools+=("azure-cli")
    fi

    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi

    log_success "All required tools present"
}

validate_azure_login() {
    log_info "Checking Azure authentication..."

    if ! az account show &>/dev/null; then
        log_error "Not authenticated to Azure. Run: az login"
        exit 1
    fi

    local account=$(az account show --query "user.name" -o tsv)
    log_success "Authenticated as: $account"
}

# Terraform functions
terraform_init() {
    log_info "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    terraform init -upgrade
    log_success "Terraform initialized"
}

terraform_fmt() {
    log_info "Formatting Terraform code..."
    cd "$TERRAFORM_DIR"
    terraform fmt -recursive
    log_success "Terraform formatting completed"
}

terraform_validate() {
    log_info "Validating Terraform configuration..."
    cd "$TERRAFORM_DIR"
    terraform validate
    log_success "Terraform configuration is valid"
}

terraform_plan() {
    log_info "Planning infrastructure changes..."
    cd "$TERRAFORM_DIR"

    terraform plan \
        -var "environment=$ENVIRONMENT" \
        -var-file="env/$ENVIRONMENT.tfvars" \
        -out="$SCRIPT_DIR/logs/plan-$ENVIRONMENT-$TIMESTAMP.tfplan" \
        -lock=true

    log_success "Plan completed: $SCRIPT_DIR/logs/plan-$ENVIRONMENT-$TIMESTAMP.tfplan"
}

terraform_apply() {
    log_info "Applying infrastructure changes..."
    cd "$TERRAFORM_DIR"

    # Require approval for production
    if [ "$ENVIRONMENT" = "prod" ]; then
        log_warning "Applying changes to PRODUCTION environment"
        read -p "Type 'yes' to confirm: " -r confirmation
        if [ "$confirmation" != "yes" ]; then
            log_warning "Deployment cancelled by user"
            return 1
        fi
    fi

    terraform apply \
        -var "environment=$ENVIRONMENT" \
        -var-file="env/$ENVIRONMENT.tfvars" \
        -auto-approve

    log_success "Infrastructure deployed successfully"
}

terraform_destroy() {
    log_warning "Destroying infrastructure in $ENVIRONMENT environment"
    cd "$TERRAFORM_DIR"

    read -p "Type environment name to confirm: " -r confirmation
    if [ "$confirmation" != "$ENVIRONMENT" ]; then
        log_error "Confirmation failed. Destroy cancelled."
        return 1
    fi

    terraform destroy \
        -var "environment=$ENVIRONMENT" \
        -var-file="env/$ENVIRONMENT.tfvars" \
        -auto-approve

    log_success "Infrastructure destroyed"
}

# Post-deployment validation
validate_deployment() {
    log_info "Validating deployment..."

    # Get resource group name
    local resource_group="${ENVIRONMENT}-rg-app-001"

    # Check if resource group exists
    if ! az group exists --name "$resource_group" | grep -q true; then
        log_error "Resource group not found: $resource_group"
        return 1
    fi

    log_success "Resource group exists: $resource_group"

    # List deployed resources
    log_info "Deployed resources:"
    az resource list --resource-group "$resource_group" --query "[].{name:name, type:type}" -o table | tee -a "$LOG_FILE"

    log_success "Deployment validation completed"
}

# Main execution
main() {
    log_info "Starting Azure infrastructure deployment"
    log_info "Environment: $ENVIRONMENT | Action: $ACTION"

    validate_environment
    validate_prerequisites
    validate_azure_login
    terraform_init
    terraform_fmt
    terraform_validate

    case $ACTION in
        plan)
            terraform_plan
            ;;
        apply)
            terraform_apply
            validate_deployment
            ;;
        destroy)
            terraform_destroy
            ;;
        *)
            log_error "Invalid action. Must be: plan, apply, or destroy"
            exit 1
            ;;
    esac

    log_success "Deployment script completed successfully"
}

# Run main function
main "$@"
