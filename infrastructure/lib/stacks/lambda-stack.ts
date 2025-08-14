import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as kms from 'aws-cdk-lib/aws-kms';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';
import * as path from 'path';

export class LambdaStack extends cdk.Stack {
  public readonly functionUrl: string;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Validate required environment variables
    if (!process.env.FLOW_SHARED_SECRET) {
      throw new Error('FLOW_SHARED_SECRET environment variable is required');
    }
    if (!process.env.SLACK_WEBHOOK_URL) {
      throw new Error('SLACK_WEBHOOK_URL environment variable is required');
    }

    // Create KMS key for log encryption
    const logEncryptionKey = new kms.Key(this, 'LogEncryptionKey', {
      description: 'KMS key for encrypting CloudWatch logs',
      enableKeyRotation: true,
      policy: new iam.PolicyDocument({
        statements: [
          new iam.PolicyStatement({
            sid: 'Enable CloudWatch Logs',
            principals: [new iam.ServicePrincipal(`logs.${cdk.Stack.of(this).region}.amazonaws.com`)],
            actions: [
              'kms:Encrypt',
              'kms:Decrypt',
              'kms:ReEncrypt*',
              'kms:GenerateDataKey*',
              'kms:DescribeKey'
            ],
            resources: ['*'],
          }),
          new iam.PolicyStatement({
            sid: 'Enable IAM User Permissions',
            principals: [new iam.AccountRootPrincipal()],
            actions: ['kms:*'],
            resources: ['*'],
          })
        ]
      })
    });

    // Create the Lambda function
    const helloWorldHook = new lambda.Function(this, 'HelloWorldHook', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'handlers/index.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../../services/hello-world-hook/dist')),
      timeout: cdk.Duration.seconds(30),
      memorySize: 128,
      logRetention: logs.RetentionDays.ONE_WEEK,
      logRetentionRetryOptions: {
        maxRetries: 3
      },
      environment: {
        FLOW_SHARED_SECRET: process.env.FLOW_SHARED_SECRET!,
        SLACK_WEBHOOK_URL: process.env.SLACK_WEBHOOK_URL!,
        NODE_OPTIONS: '--enable-source-maps',
        AWS_NODEJS_CONNECTION_REUSE_ENABLED: '1'
      },
      description: 'Shopify Flow webhook handler that posts to Slack'
    });

    // Create encrypted log group
    new logs.LogGroup(this, 'HelloWorldHookLogGroup', {
      logGroupName: `/aws/lambda/${helloWorldHook.functionName}`,
      retention: logs.RetentionDays.ONE_WEEK,
      encryptionKey: logEncryptionKey,
      removalPolicy: cdk.RemovalPolicy.DESTROY
    });

    // Create Function URL
    const functionUrl = helloWorldHook.addFunctionUrl({
      authType: lambda.FunctionUrlAuthType.NONE,
      cors: {
        allowCredentials: false,
        allowedMethods: [lambda.HttpMethod.POST],
        allowedOrigins: ['*'],
        allowedHeaders: ['content-type', 'authorization']
      }
    });

    this.functionUrl = functionUrl.url;

    // Output the Function URL
    new cdk.CfnOutput(this, 'FunctionUrl', {
      value: functionUrl.url,
      description: 'Lambda Function URL for Shopify Flow webhook'
    });
  }
}