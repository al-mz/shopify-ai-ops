# Infrastructure

AWS CDK infrastructure for Shopify AI Ops project.

## Quick Start

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Build Lambda function**
   ```bash
   cd ../services/order-notification-handler
   npm install
   npm run build
   cd ../infrastructure
   ```

3. **Set environment variables**
   ```bash
   export FLOW_SHARED_SECRET=$(openssl rand -hex 32)
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
   echo "Save this secret for Flow: $FLOW_SHARED_SECRET"
   ```

4. **Bootstrap CDK (first time only)**
   ```bash
   npx cdk bootstrap
   ```

5. **Deploy the stack**
   ```bash
   npm run deploy
   ```

6. **Copy the Function URL from CDK output for Shopify Flow configuration**

## Commands

- `npm run build` - Compile TypeScript
- `npm run deploy` - Deploy to AWS
- `npm run destroy` - Remove from AWS  
- `npm run diff` - See changes before deploy
- `npm run synth` - Generate CloudFormation template

## Testing

Test the deployed function (should return 401 without auth):
```bash
curl -X POST https://your-function-url.lambda-url.region.on.aws/ \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
# Expected: 401 Unauthorized
```

## Architecture

- **Lambda Function**: Node.js 18.x runtime with Function URL
- **Memory**: 128MB 
- **Timeout**: 30 seconds
- **Environment Variables**: FLOW_SHARED_SECRET, SLACK_WEBHOOK_URL