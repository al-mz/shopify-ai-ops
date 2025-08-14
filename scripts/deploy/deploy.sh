#!/bin/bash

# Shopify AI Ops - AWS Deployment Script
# This script deploys the Lambda function and infrastructure to AWS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to load environment variables
load_env() {
    if [[ -f .env ]]; then
        log_info "Loading environment variables from .env file"
        export $(cat .env | grep -v '^#' | xargs)
    else
        log_error ".env file not found!"
        log_info "Please create a .env file based on .env.example:"
        log_info "cp .env.example .env"
        log_info "Then edit .env with your actual values"
        exit 1
    fi
}

# Function to validate required environment variables
validate_env() {
    log_info "Validating required environment variables..."
    
    local missing_vars=()
    
    # Required for deployment
    [[ -z "${FLOW_SHARED_SECRET:-}" ]] && missing_vars+=("FLOW_SHARED_SECRET")
    [[ -z "${SLACK_WEBHOOK_URL:-}" ]] && missing_vars+=("SLACK_WEBHOOK_URL")
    [[ -z "${AWS_REGION:-}" ]] && missing_vars+=("AWS_REGION")
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            log_error "  - $var"
        done
        log_info "Please set these variables in your .env file"
        exit 1
    fi
    
    # Validate SLACK_WEBHOOK_URL format
    if [[ ! "$SLACK_WEBHOOK_URL" =~ ^https://hooks\.slack\.com/services/.+ ]]; then
        log_error "SLACK_WEBHOOK_URL must be a valid Slack webhook URL"
        log_info "Format: https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
        exit 1
    fi
    
    # Validate FLOW_SHARED_SECRET length (should be strong)
    if [[ ${#FLOW_SHARED_SECRET} -lt 32 ]]; then
        log_warning "FLOW_SHARED_SECRET should be at least 32 characters for security"
        log_warning "Consider generating a stronger secret: openssl rand -hex 32"
    fi
    
    log_success "Environment variables validated successfully"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if AWS CLI is installed and configured
    if ! command_exists aws; then
        log_error "AWS CLI is not installed. Please install it first:"
        log_info "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS credentials not configured or expired"
        log_info "Please configure AWS credentials using 'aws configure' or environment variables"
        exit 1
    fi
    
    # Check if CDK is available (global or local)
    if ! command_exists cdk && ! [[ -f infrastructure/node_modules/.bin/cdk ]]; then
        log_error "AWS CDK is not installed. Installing locally..."
        cd infrastructure
        npm install aws-cdk
        cd ..
        log_info "CDK installed locally in infrastructure project"
    fi
    
    # Check if Node.js is installed
    if ! command_exists node; then
        log_error "Node.js is not installed. Please install Node.js 18 or later"
        exit 1
    fi
    
    # Check Node.js version
    local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $node_version -lt 18 ]]; then
        log_error "Node.js version 18 or later is required. Current version: $(node --version)"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Function to build the project
build_project() {
    log_info "Building the project..."
    
    # Build Lambda function
    log_info "Building order notification handler..."
    cd services/order-notification-handler
    
    if [[ ! -f package.json ]]; then
        log_error "package.json not found in services/order-notification-handler"
        exit 1
    fi
    
    npm install
    npm run build
    npm test
    
    cd ../..
    
    # Build CDK infrastructure
    log_info "Building CDK infrastructure..."
    cd infrastructure
    
    if [[ ! -f package.json ]]; then
        log_error "package.json not found in infrastructure"
        exit 1
    fi
    
    npm install
    npm run build
    
    cd ..
    
    log_success "Project built successfully"
}

# Function to bootstrap CDK (if needed)
bootstrap_cdk() {
    log_info "Checking CDK bootstrap status..."
    
    # Set default region if not specified
    export CDK_DEFAULT_REGION=${AWS_REGION}
    
    # Get AWS account ID
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    export CDK_DEFAULT_ACCOUNT=$account_id
    
    log_info "AWS Account: $account_id"
    log_info "AWS Region: $AWS_REGION"
    
    # Check if CDK is already bootstrapped
    if aws cloudformation describe-stacks --stack-name CDKToolkit --region $AWS_REGION >/dev/null 2>&1; then
        log_info "CDK already bootstrapped in region $AWS_REGION"
    else
        log_info "Bootstrapping CDK in region $AWS_REGION..."
        cd infrastructure
        npx cdk bootstrap aws://$account_id/$AWS_REGION
        cd ..
        log_success "CDK bootstrapped successfully"
    fi
}

# Function to deploy the stack
deploy_stack() {
    log_info "Deploying Lambda stack to AWS..."
    
    cd infrastructure
    
    # Deploy with environment variables
    log_info "Deploying with CDK..."
    npx cdk deploy --require-approval never
    
    cd ..
    
    log_success "Stack deployed successfully!"
}

# Function to get deployment outputs
get_outputs() {
    log_info "Retrieving deployment outputs..."
    
    cd infrastructure
    
    # Get the Function URL
    # Try to get the Function URL from stack outputs
    local function_url=""
    if npx cdk list 2>/dev/null | grep -q "ShopifyAiOpsStack"; then
        function_url=$(aws cloudformation describe-stacks --stack-name ShopifyAiOpsStack --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='FunctionUrl'].OutputValue" --output text 2>/dev/null || echo "")
    fi
    
    if [[ -n "$function_url" ]]; then
        log_success "Deployment completed!"
        echo ""
        log_info "🚀 Function URL: $function_url"
        echo ""
        log_info "📝 Next steps:"
        log_info "1. Test your endpoint:"
        log_info "   curl -X POST \"$function_url\" \\"
        log_info "        -H \"Authorization: Bearer $FLOW_SHARED_SECRET\" \\"
        log_info "        -H \"Content-Type: application/json\" \\"
        log_info "        -d '{\"orderId\": \"test-123\", \"name\": \"#1001\", \"total\": \"99.99\"}'"
        echo ""
        log_info "2. Configure Shopify Flow with this URL"
        log_info "3. Use this Bearer token in Shopify Flow: $FLOW_SHARED_SECRET"
        echo ""
    else
        log_warning "Could not retrieve Function URL. Check AWS Console for deployment status."
    fi
    
    cd ..
}

# Function to show help
show_help() {
    echo "Shopify AI Ops - AWS Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --build-only   Only build the project, don't deploy"
    echo "  --deploy-only  Only deploy, skip build (use with caution)"
    echo ""
    echo "Prerequisites:"
    echo "  - AWS CLI installed and configured"
    echo "  - AWS CDK installed (npm install -g aws-cdk)"
    echo "  - Node.js 18+ installed"
    echo "  - .env file with required variables (copy from .env.example)"
    echo ""
    echo "Required environment variables:"
    echo "  - FLOW_SHARED_SECRET: Secret for Shopify Flow authentication"
    echo "  - SLACK_WEBHOOK_URL: Slack incoming webhook URL"
    echo "  - AWS_REGION: AWS region for deployment"
    echo ""
}

# Main function
main() {
    echo ""
    log_info "🚀 Starting Shopify AI Ops deployment..."
    echo ""
    
    # Parse command line arguments
    local build_only=false
    local deploy_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --build-only)
                build_only=true
                shift
                ;;
            --deploy-only)
                deploy_only=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Load and validate environment
    load_env
    validate_env
    check_prerequisites
    
    if [[ "$deploy_only" == false ]]; then
        build_project
    fi
    
    if [[ "$build_only" == false ]]; then
        bootstrap_cdk
        deploy_stack
        get_outputs
    fi
    
    echo ""
    log_success "✅ Deployment process completed!"
    echo ""
}

# Run main function with all arguments
main "$@"