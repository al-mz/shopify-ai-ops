# 🚀 Deployment Guide - Shopify AI Ops

This guide will help you deploy the Shopify AI Ops Lambda function to AWS.

## Prerequisites

Before deploying, ensure you have:

- ✅ AWS CLI installed and configured with credentials
- ✅ AWS CDK installed globally (`npm install -g aws-cdk`)
- ✅ Node.js 18+ installed
- ✅ A Slack workspace with webhook permissions

## Quick Start

### 1. Set up Environment Variables

Copy the example environment file:
```bash
cp .env.example .env
```

Edit the `.env` file with your actual values:
```bash
# Required for deployment
FLOW_SHARED_SECRET=your-secure-secret-here    # Generate with: openssl rand -hex 32
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
AWS_REGION=us-east-1                          # Your preferred AWS region
```

### 2. Get Your Slack Webhook URL

1. Go to https://api.slack.com/apps
2. Create a new app or select an existing one
3. Go to "Incoming Webhooks"
4. Activate incoming webhooks
5. Add a new webhook to your desired channel
6. Copy the webhook URL to your `.env` file

### 3. Generate a Secure Secret

Generate a strong secret for Shopify Flow authentication:
```bash
openssl rand -hex 32
```

Add this to your `.env` file as `FLOW_SHARED_SECRET`.

### 4. Deploy to AWS

Run the deployment script:
```bash
./deploy.sh
```

The script will:
- ✅ Validate your environment variables
- ✅ Check prerequisites
- ✅ Build the Lambda function
- ✅ Build the CDK infrastructure
- ✅ Bootstrap CDK (if needed)
- ✅ Deploy to AWS
- ✅ Show you the Function URL

## Deployment Options

### Full Deployment (Recommended)
```bash
./deploy.sh
```

### Build Only (for testing)
```bash
./deploy.sh --build-only
```

### Deploy Only (skip build)
```bash
./deploy.sh --deploy-only
```

### Help
```bash
./deploy.sh --help
```

## After Deployment

Once deployed, you'll get a Function URL like:
```
https://abc123xyz.lambda-url.us-east-1.on.aws/
```

### Test Your Endpoint

```bash
curl -X POST "YOUR_FUNCTION_URL" \
     -H "Authorization: Bearer YOUR_FLOW_SHARED_SECRET" \
     -H "Content-Type: application/json" \
     -d '{"orderId": "test-123", "name": "#1001", "total": "99.99"}'
```

Expected response:
```json
{"message":"Success","requestId":"abc123-def456-ghi789"}
```

### Configure Shopify Flow

1. In your Shopify admin, go to Settings > Notifications
2. Create a new Flow
3. Add an "Order created" trigger
4. Add an "HTTP request" action with:
   - **URL**: Your Function URL
   - **Method**: POST
   - **Headers**: 
     - `Authorization: Bearer YOUR_FLOW_SHARED_SECRET`
     - `Content-Type: application/json`
   - **Body**: JSON with order data

## Troubleshooting

### Common Issues

**Error: ".env file not found!"**
- Solution: Copy `.env.example` to `.env` and fill in your values

**Error: "AWS credentials not configured"**
- Solution: Run `aws configure` or set AWS environment variables

**Error: "CDK is not installed"**
- Solution: Install CDK globally: `npm install -g aws-cdk`

**Error: "SLACK_WEBHOOK_URL must be a valid Slack webhook URL"**
- Solution: Ensure your webhook URL starts with `https://hooks.slack.com/services/`

### Viewing Logs

Check CloudWatch logs in AWS Console:
```
AWS Console > CloudWatch > Log groups > /aws/lambda/ShopifyAiOpsStack-HelloWorldHook*
```

### Clean Up Resources

To remove all deployed resources:
```bash
cd infrastructure
cdk destroy
```

## Security Notes

- 🔒 **Never commit your `.env` file** - it's already in `.gitignore`
- 🔒 **Use a strong FLOW_SHARED_SECRET** (32+ characters)
- 🔒 **Regularly rotate your secrets**
- 🔒 **Monitor CloudWatch logs for unauthorized access attempts**

## Next Steps

After successful deployment:

1. ✅ Test the endpoint manually
2. ✅ Configure Shopify Flow
3. ✅ Test end-to-end with a real order
4. ✅ Monitor CloudWatch logs
5. ✅ Set up alerts for errors (optional)

## Support

If you encounter issues:

1. Check the deployment logs
2. Verify your `.env` file values
3. Check AWS CloudWatch logs
4. Ensure AWS credentials have sufficient permissions

For more details, see the project documentation in `/docs/`.