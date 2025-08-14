# Shopify AI Ops

A serverless pipeline that connects Shopify Flow to AWS Lambda and Slack for automated order processing and notifications.

## Quick Start

1. **Clone and setup**:
   ```bash
   git clone https://github.com/yourusername/shopify-ai-ops
   cd shopify-ai-ops
   cp .env.example .env
   ```

2. **Configure environment variables**:
   ```bash
   FLOW_SHARED_SECRET=$(openssl rand -hex 32)
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
   AWS_REGION=us-east-1
   ```

3. **Deploy**:
   ```bash
   ./scripts/deploy/deploy.sh
   ```

## Architecture

```
Shopify Store → Shopify Flow → AWS Lambda → Slack
```

- **Shopify Flow**: Triggers on order creation
- **AWS Lambda**: Processes webhook and formats message
- **Slack**: Receives real-time order notifications

## Tech Stack

- **Runtime**: Node.js 18, TypeScript
- **Infrastructure**: AWS CDK, AWS Lambda Function URLs
- **Security**: Bearer token authentication, encrypted CloudWatch logs
- **Deployment**: One-command deployment script

## Project Structure

```
shopify-ai-ops/
├── services/
│   ├── order-notification-handler/     # Main Lambda function
│   └── shared/                          # Shared utilities
├── infrastructure/                      # AWS CDK code
├── scripts/deploy/                      # Deployment automation
└── docs/                               # Documentation
```

## Development

```bash
# Install dependencies
npm install

# Build all services
npm run build

# Run tests
npm test

# Deploy to AWS
make deploy-dev
```

## Features

- ✅ **Serverless**: Pay-per-use, automatic scaling
- ✅ **Secure**: Bearer token authentication, encrypted logs
- ✅ **Fast**: <1 second response time
- ✅ **Cost-effective**: ~$0.01/month for POC usage
- ✅ **Monitored**: Structured logging with CloudWatch

## Configuration

### Shopify Flow Setup

1. Create workflow with "Order created" trigger
2. Add "Send HTTP request" action:
   - **URL**: Your Lambda Function URL
   - **Method**: POST
   - **Headers**: `Authorization: Bearer YOUR_SECRET`
   - **Body**: Order JSON data

### Slack Setup

1. Create Slack app at [api.slack.com](https://api.slack.com)
2. Enable "Incoming Webhooks"
3. Add webhook to desired channel
4. Copy webhook URL to `.env` file

## Requirements

- AWS account with CLI configured
- Node.js 18+
- Shopify Partner account (for development store)
- Slack workspace admin access
