# Hello World Hook

## Overview

AWS Lambda function that receives webhooks from Shopify Flow, validates authentication, and forwards messages to Slack.

## Quick Start

1. `npm install`
2. Set environment variables (see .env.example in project root)
3. Build: `npm run build`
4. Deploy via CDK from infrastructure directory: `npm run deploy`

## Commands

- `npm run build` - Compile TypeScript to JavaScript
- `npm run watch` - Watch for changes and recompile
- `npm run test` - Run unit tests
- `npm run clean` - Remove dist directory

## Environment Variables

- `FLOW_SHARED_SECRET` - Bearer token for authentication
- `SLACK_WEBHOOK_URL` - Slack incoming webhook URL

## Architecture

- **Runtime**: Node.js 18.x
- **Memory**: 128MB
- **Timeout**: 30 seconds
- **Handler**: `dist/handlers/index.handler`

## Testing

The function expects POST requests with:
- Authorization header: `Bearer <FLOW_SHARED_SECRET>`
- JSON body with order data from Shopify Flow