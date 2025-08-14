import { handler } from '../../src/handlers/index';
import { APIGatewayProxyEvent, Context } from 'aws-lambda';

// Mock environment variables
process.env.FLOW_SHARED_SECRET = 'test-secret-123';
process.env.SLACK_WEBHOOK_URL = 'https://hooks.slack.com/test';

// Mock fetch globally
global.fetch = jest.fn();

describe('order-notification-handler', () => {
  const mockContext: Context = {
    awsRequestId: 'test-request-id',
    callbackWaitsForEmptyEventLoop: false,
    functionName: 'test-function',
    functionVersion: '1',
    invokedFunctionArn: 'arn:aws:lambda:us-east-1:123456789012:function:test',
    logGroupName: '/aws/lambda/test',
    logStreamName: 'test-stream',
    memoryLimitInMB: '128',
    getRemainingTimeInMillis: () => 30000,
    done: jest.fn(),
    fail: jest.fn(),
    succeed: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return 401 for missing authorization header', async () => {
    const event: Partial<APIGatewayProxyEvent> = {
      httpMethod: 'POST',
      headers: {},
      body: '{"test": "data"}'
    };

    const result = await handler(event as APIGatewayProxyEvent, mockContext);

    expect(result.statusCode).toBe(401);
    expect(JSON.parse(result.body)).toEqual({ error: 'Unauthorized' });
  });

  it('should return 401 for incorrect bearer token', async () => {
    const event: Partial<APIGatewayProxyEvent> = {
      httpMethod: 'POST',
      headers: {
        authorization: 'Bearer wrong-token'
      },
      body: '{"test": "data"}'
    };

    const result = await handler(event as APIGatewayProxyEvent, mockContext);

    expect(result.statusCode).toBe(401);
    expect(JSON.parse(result.body)).toEqual({ error: 'Unauthorized' });
  });

  it('should return 200 for correct bearer token', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      status: 200,
      text: () => Promise.resolve('ok')
    });

    const event: Partial<APIGatewayProxyEvent> = {
      httpMethod: 'POST',
      headers: {
        authorization: 'Bearer test-secret-123'
      },
      body: '{"orderId": "123", "name": "#1001", "total": "99.99"}'
    };

    const result = await handler(event as APIGatewayProxyEvent, mockContext);

    expect(result.statusCode).toBe(200);
    const responseBody = JSON.parse(result.body);
    expect(responseBody.message).toBe('Success');
    expect(responseBody.requestId).toBe('test-request-id');
    expect(fetch).toHaveBeenCalledWith(
      'https://hooks.slack.com/test',
      expect.objectContaining({
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      })
    );
  });
});