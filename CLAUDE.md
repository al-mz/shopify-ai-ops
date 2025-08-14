# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shopify AI Ops** is a serverless pipeline project that connects Shopify Flow to AWS Lambda and Slack for automated order processing and notifications. The project follows a multi-week development approach, starting with a minimal MVP foundation in Week 0.

## Project Goals

This is a proof-of-concept (POC) implementation that demonstrates:
- **Pipeline Architecture**: Shopify Flow → HTTPS → AWS Lambda (Function URL) → Slack
- **Serverless Foundation**: AWS Lambda-based processing without infrastructure management
- **Authentication**: Bearer token security between components
- **Real-time Notifications**: Automated Slack notifications for order events
- **Scalable Architecture**: Foundation for future AI-powered features

## Development Phases

### Week 0 - MVP Foundation (Current Phase)
- **Objective**: Stand up the reusable pipeline with AWS components
- **Scope**: Hello-world Lambda function that receives Shopify Flow webhooks and posts to Slack
- **Architecture**: 
  - AWS Lambda (Node.js 18 or Python 3.12) with Function URL
  - Shopify Flow with "Order created" trigger
  - Slack Incoming Webhook integration
  - Bearer token authentication
  - CloudWatch Logs for debugging

### Future Weeks
- Week 1+: Add AI integration for returns processing with Admin API GraphQL calls
- Enhanced error handling and performance monitoring

## Repository Structure

```
shopify-ai-ops/
├── docs/
│   └── claude/
│       └── week0/
│           ├── project-goals.md        # Week 0 technical objectives
│           └── week0-mvp-foundation-prd.md  # Detailed PRD with 6 stories
├── apps/                              # Lambda functions (to be created)
├── flows/                             # Shopify Flow exports (to be created) 
└── CLAUDE.md                          # This file
```

## Key Technologies & Architecture

- **AWS Lambda**: Serverless compute with Function URL (no API Gateway needed for MVP)
- **Shopify Flow**: Native Shopify automation platform for webhooks
- **Node.js 18**: Preferred runtime for Lambda functions
- **Bearer Token Authentication**: Simple but secure server-to-server auth
- **CloudWatch**: Logging and monitoring

## Development Workflow

Based on the PRD, development follows 6 main stories:
1. **AWS Lambda Setup**: CDK-based infrastructure with Function URL
2. **Slack Integration**: Incoming Webhooks configuration  
3. **Shopify Flow Configuration**: Order creation triggers with HTTP actions
4. **Security Implementation**: Bearer token auth and monitoring
5. **Repository Structure**: Documentation and code organization
6. **Testing & Validation**: End-to-end testing with success criteria

## Security Considerations

- **Environment Variables**: Store secrets (FLOW_SHARED_SECRET, SLACK_WEBHOOK_URL) in Lambda env vars
- **Public Function URL**: Protected by Bearer token validation in code
- **No Sensitive Logging**: Avoid logging secrets to CloudWatch
- **Token Rotation**: Establish regular secret rotation procedures

## Success Criteria

- End-to-end pipeline completes in ≤15 seconds
- Authentication properly rejects invalid tokens (401 response)
- One-shot deployment in <30 minutes via AWS Console
- Flow portability through JSON export/import
- Complete documentation enabling reproduction

## Current State

This repository is in the initial setup phase. The documentation in `docs/claude/week0/` provides the complete technical specification for implementing the Week 0 MVP Foundation.

## Next Steps for Implementation

1. Create AWS Lambda function with CDK (preferred) or AWS Console
2. Set up Slack Incoming Webhook integration
3. Configure Shopify Flow with order creation triggers
4. Implement Bearer token authentication
5. Create proper repository structure with documentation
6. Perform end-to-end testing and validation

## Notes for Future Development

- The Lambda pattern established in Week 0 is designed to be reusable for future functions
- Repository structure supports scaling to multiple apps and flows
- Monitoring foundation with CloudWatch is ready for production enhancement
- Authentication model can extend to Admin API integration in later phases