# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shopify AI Ops** is a serverless pipeline project that connects Shopify Flow to AWS Lambda and Slack for automated order processing and notifications. The project follows a multi-week development approach, starting with a minimal MVP foundation in Week 0.

**Current Status**: Week 0 MVP is complete and deployed. The order notification handler is live and processing real Shopify orders.

## Architecture Overview

The system implements a serverless event-driven architecture:

```
Shopify Store → Shopify Flow → AWS Lambda (Function URL) → Slack
```

**Key Components:**
- **Order Notification Handler**: Lambda function processing Shopify order events
- **CDK Infrastructure**: Infrastructure as Code defining AWS resources
- **Monorepo Structure**: NPM workspaces with shared libraries and multiple services
- **Deployment Automation**: Scripts for environment-specific deployments

## Common Commands

### Development Workflow
```bash
# Initial setup
make bootstrap               # Install deps + CDK bootstrap
npm run build               # Build all packages (shared → services → infrastructure)

# Development
npm test                    # Run all tests
npm run test:unit          # Unit tests only
make test-e2e              # End-to-end tests
npm run lint               # Linting
npm run format             # Code formatting

# Service-specific (from service directory)
cd services/order-notification-handler
npm run build              # Build single service
npm run watch              # Watch mode for development
npm test                   # Service-specific tests
```

### Deployment
```bash
# Quick deployment (uses custom script)
./scripts/deploy/deploy.sh  # Full automated deployment with validation

# CDK-based deployment
make deploy-dev             # Deploy to development
make deploy-staging         # Deploy to staging  
make deploy-prod           # Deploy to production (requires approval)

# Infrastructure management
make diff                  # Show deployment changes
make synth                 # Generate CloudFormation templates
```

### Testing and Debugging
```bash
make logs                  # Tail CloudWatch logs
make webhook-test          # Test webhook locally
npm run logs               # Alternative log tailing
```

## Repository Structure

This is a **monorepo** using NPM workspaces with the following key areas:

```
shopify-ai-ops/
├── services/
│   ├── order-notification-handler/     # Main Lambda function (Node.js 18)
│   └── shared/                          # Shared libraries and types
├── infrastructure/                      # AWS CDK infrastructure definitions
├── scripts/deploy/                      # Deployment automation
└── docs/claude/week0/                   # Technical specifications
```

## Technical Implementation

### Lambda Function Architecture
The `order-notification-handler` follows these patterns:
- **Structured Logging**: JSON logs with request correlation IDs
- **Environment Variable Validation**: Fails fast if required secrets missing
- **Bearer Token Authentication**: Validates `FLOW_SHARED_SECRET` on every request
- **Error Handling**: Returns proper HTTP status codes (400, 401, 500, 502)
- **Slack Integration**: Posts formatted order notifications via webhook

### CDK Infrastructure Patterns
- **KMS Encryption**: CloudWatch logs encrypted with auto-rotating keys
- **Function URLs**: Direct HTTPS access without API Gateway
- **Log Retention**: 1-week retention for cost optimization
- **Environment-Specific**: Supports dev/staging/prod deployments

### Security Implementation
- **Secrets Management**: Environment variables for sensitive data (never hardcoded)
- **Request Validation**: Bearer token + JSON schema validation
- **Log Security**: No sensitive data logged to CloudWatch
- **HTTPS Only**: All communication encrypted in transit

## Environment Configuration

The system requires these environment variables:

```bash
# Required for deployment
FLOW_SHARED_SECRET=<32-char-secret>     # Generate with: openssl rand -hex 32
SLACK_WEBHOOK_URL=<slack-webhook-url>   # From Slack app incoming webhook
AWS_REGION=<aws-region>                 # Target deployment region
```

Copy `.env.example` to `.env` and configure before deployment.

## Deployment Architecture

**Development Flow:**
1. **Local Development**: Build and test services individually
2. **Validation**: Automated script validates prerequisites and environment
3. **CDK Bootstrap**: One-time setup per AWS account/region
4. **Stack Deployment**: Lambda function + infrastructure deployed together
5. **Verification**: Function URL returned for Shopify Flow configuration

**Infrastructure Components:**
- Lambda Function with Function URL
- KMS Key for log encryption
- CloudWatch Log Group with retention policy
- IAM roles and policies (managed by CDK)

## Testing Strategy

**Unit Tests**: Jest-based testing for Lambda handlers
- Mock AWS services and external APIs
- Test authentication, validation, and error handling
- Structured logging verification

**Integration Tests**: End-to-end pipeline testing
- Real Shopify Flow → Lambda → Slack integration
- Environment-specific testing

## Development Patterns

When adding new Lambda functions:
1. **Follow Service Structure**: Use `order-notification-handler` as template
2. **Shared Libraries**: Leverage `services/shared` for common utilities
3. **CDK Patterns**: Extend existing stack patterns for consistency
4. **Testing**: Maintain unit test coverage with integration tests
5. **Environment Variables**: Always validate required configuration