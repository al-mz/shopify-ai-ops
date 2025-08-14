# Shopify AI Ops - Project Structure

## Directory Structure Overview

```
shopify-ai-ops/
├── .github/                          # GitHub specific configurations
│   ├── workflows/                    # GitHub Actions CI/CD pipelines
│   │   ├── deploy-dev.yml           # Development environment deployment
│   │   ├── deploy-prod.yml          # Production environment deployment
│   │   ├── pr-validation.yml        # Pull request validation
│   │   └── release.yml              # Release automation
│   ├── ISSUE_TEMPLATE/              # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md     # PR template
│   └── dependabot.yml               # Dependency updates configuration
│
├── infrastructure/                    # AWS CDK Infrastructure as Code
│   ├── bin/                          # CDK app entry points
│   │   └── shopify-ai-ops.ts       # Main CDK application
│   ├── lib/                          # CDK stack definitions
│   │   ├── stacks/                  # Individual stack definitions
│   │   │   ├── lambda-stack.ts     # Lambda functions stack
│   │   │   ├── api-stack.ts        # API Gateway stack
│   │   │   ├── monitoring-stack.ts # CloudWatch monitoring stack
│   │   │   ├── network-stack.ts    # VPC and networking stack
│   │   │   └── storage-stack.ts    # S3, DynamoDB resources
│   │   ├── constructs/              # Reusable CDK constructs
│   │   │   ├── lambda-function.ts  # Enhanced Lambda construct
│   │   │   ├── slack-integration.ts # Slack notification construct
│   │   │   └── shopify-webhook.ts  # Shopify webhook construct
│   │   └── config/                  # CDK configuration
│   │       ├── stages.ts            # Environment stage definitions
│   │       └── tags.ts              # Resource tagging strategy
│   ├── test/                         # CDK infrastructure tests
│   │   ├── stacks/                  # Stack-specific tests
│   │   └── constructs/              # Construct-specific tests
│   ├── cdk.json                     # CDK configuration
│   ├── package.json                 # CDK dependencies
│   ├── tsconfig.json                # TypeScript config for CDK
│   └── jest.config.js               # Jest configuration for CDK tests
│
├── services/                          # Lambda functions and microservices
│   ├── hello-world-hook/            # First Lambda function
│   │   ├── src/                     # Source code
│   │   │   ├── handlers/           # Lambda handler functions
│   │   │   │   └── index.ts       # Main handler
│   │   │   ├── services/           # Business logic
│   │   │   │   ├── shopify.ts     # Shopify API interactions
│   │   │   │   └── slack.ts       # Slack notifications
│   │   │   ├── utils/              # Utility functions
│   │   │   │   ├── logger.ts      # Structured logging
│   │   │   │   └── validator.ts   # Input validation
│   │   │   └── types/              # TypeScript type definitions
│   │   │       └── index.ts       # Type exports
│   │   ├── tests/                   # Function-specific tests
│   │   │   ├── unit/               # Unit tests
│   │   │   └── integration/        # Integration tests
│   │   ├── package.json             # Function dependencies
│   │   ├── tsconfig.json            # TypeScript config
│   │   └── README.md               # Function documentation
│   │
│   ├── order-processor/              # Future: Order processing Lambda
│   ├── inventory-sync/              # Future: Inventory sync Lambda
│   └── shared/                      # Shared code across services
│       ├── lib/                     # Shared libraries
│       │   ├── shopify-client/     # Shopify API client
│       │   ├── slack-client/       # Slack API client
│       │   └── aws-clients/        # AWS SDK clients
│       ├── types/                   # Shared TypeScript types
│       └── package.json             # Shared dependencies
│
├── shopify-flows/                    # Shopify Flow configurations
│   ├── flows/                       # Flow definition files
│   │   ├── hello-world/            # Hello World flow
│   │   │   ├── flow.json           # Flow configuration
│   │   │   ├── README.md           # Flow documentation
│   │   │   └── test-payload.json   # Test webhook payload
│   │   └── templates/              # Reusable flow templates
│   ├── scripts/                     # Flow deployment scripts
│   │   ├── deploy-flow.ts          # Deploy flow to Shopify
│   │   └── validate-flow.ts        # Validate flow configuration
│   └── README.md                    # Flows documentation
│
├── config/                           # Application configuration
│   ├── environments/                # Environment-specific configs
│   │   ├── dev.json                # Development configuration
│   │   ├── staging.json            # Staging configuration
│   │   └── prod.json               # Production configuration
│   ├── secrets/                     # Secret management (gitignored)
│   │   └── .gitkeep                # Placeholder
│   └── defaults.json                # Default configuration values
│
├── scripts/                          # Development and deployment scripts
│   ├── deploy/                      # Deployment scripts
│   │   ├── deploy-stack.sh         # Deploy CDK stack
│   │   ├── deploy-lambda.sh        # Deploy specific Lambda
│   │   └── full-deploy.sh          # Full deployment pipeline
│   ├── setup/                       # Setup and initialization
│   │   ├── bootstrap-aws.sh        # Bootstrap AWS CDK
│   │   ├── install-deps.sh         # Install all dependencies
│   │   └── create-secrets.sh       # Create AWS Secrets Manager entries
│   └── utils/                       # Utility scripts
│       ├── test-webhook.sh         # Test webhook locally
│       └── logs-tail.sh            # Tail CloudWatch logs
│
├── docs/                             # Project documentation
│   ├── architecture/                # Architecture documentation
│   │   ├── overview.md             # Architecture overview
│   │   ├── diagrams/               # Architecture diagrams
│   │   └── decisions/              # Architecture Decision Records (ADRs)
│   ├── guides/                      # How-to guides
│   │   ├── getting-started.md     # Getting started guide
│   │   ├── deployment.md           # Deployment guide
│   │   └── troubleshooting.md     # Troubleshooting guide
│   ├── api/                         # API documentation
│   └── flows/                       # Shopify Flow documentation
│
├── tests/                            # End-to-end and integration tests
│   ├── e2e/                         # End-to-end tests
│   │   ├── flows/                  # Flow integration tests
│   │   └── scenarios/              # Business scenario tests
│   ├── performance/                 # Performance tests
│   └── fixtures/                    # Test data and fixtures
│
├── monitoring/                       # Monitoring and observability
│   ├── dashboards/                  # CloudWatch dashboard definitions
│   │   └── main-dashboard.json     # Main monitoring dashboard
│   ├── alarms/                      # CloudWatch alarm definitions
│   │   ├── lambda-alarms.json      # Lambda function alarms
│   │   └── api-alarms.json         # API Gateway alarms
│   └── queries/                     # CloudWatch Insights queries
│
├── .vscode/                          # VS Code workspace settings
│   ├── settings.json                # Workspace settings
│   ├── launch.json                  # Debug configurations
│   └── extensions.json              # Recommended extensions
│
├── .env.example                      # Environment variables template
├── .gitignore                       # Git ignore rules
├── .nvmrc                           # Node version specification
├── .prettierrc                      # Code formatting rules
├── .eslintrc.json                   # Linting rules
├── docker-compose.yml               # Local development environment
├── Makefile                         # Common commands and tasks
├── package.json                     # Root package.json for workspaces
├── tsconfig.json                    # Root TypeScript configuration
├── lerna.json                       # Monorepo configuration (optional)
└── README.md                        # Project documentation
```

## Directory Explanations

### `/infrastructure`
Central location for all AWS CDK infrastructure code. Separates stacks for different concerns and provides reusable constructs.

**Why this structure:**
- Clear separation between stacks (compute, storage, networking)
- Reusable constructs reduce code duplication
- Isolated testing for infrastructure code
- Easy to add new stacks as project grows

### `/services`
Contains all Lambda functions and microservices. Each service is self-contained with its own dependencies.

**Why this structure:**
- Independent deployment of functions
- Service-specific testing and configuration
- Shared libraries reduce code duplication
- Easy to add new services without affecting existing ones

### `/shopify-flows`
Version-controlled Shopify Flow configurations with deployment automation.

**Why this structure:**
- Flow configurations as code
- Test payloads for development
- Automated deployment scripts
- Documentation alongside flows

### `/config`
Centralized configuration management for all environments.

**Why this structure:**
- Environment-specific configurations
- Secrets separated from code
- Default values for common settings
- Easy environment promotion

### `/scripts`
Automation scripts for common tasks.

**Why this structure:**
- Consistent deployment processes
- Developer productivity tools
- Automated setup procedures
- Reduced manual operations

### `/monitoring`
Observability configurations as code.

**Why this structure:**
- Version-controlled dashboards
- Consistent alarm definitions
- Reusable query patterns
- Infrastructure-as-code for monitoring

## Key Design Decisions

1. **Monorepo Structure**: All services in one repository for easier dependency management and atomic deployments.

2. **Service Isolation**: Each Lambda function is independent with its own package.json for optimal bundle sizes.

3. **Shared Libraries**: Common code in `/services/shared` reduces duplication while maintaining service independence.

4. **Infrastructure Separation**: CDK code separate from application code for clear boundaries.

5. **Configuration as Code**: All configurations (flows, monitoring, infrastructure) are version-controlled.

6. **Testing at Multiple Levels**: Unit tests with services, integration tests in `/tests`, CDK tests in infrastructure.

7. **Documentation Co-location**: Documentation lives next to the code it documents for better maintenance.

## Scalability Features

- **Easy Service Addition**: New Lambda functions follow the established pattern in `/services`
- **Reusable Constructs**: CDK constructs in `/infrastructure/lib/constructs` speed up development
- **Environment Management**: Clear environment separation supports dev/staging/prod workflows
- **CI/CD Ready**: GitHub Actions workflows ready for automation
- **Monitoring Built-in**: Observability configurations grow with the application

## Next Steps

1. Initialize the CDK application in `/infrastructure`
2. Create the first Lambda function in `/services/hello-world-hook`
3. Set up the Shopify Flow configuration in `/shopify-flows`
4. Configure GitHub Actions for CI/CD
5. Add monitoring dashboards and alarms