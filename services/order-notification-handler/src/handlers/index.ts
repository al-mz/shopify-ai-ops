import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

// Structured logging helper
const log = (level: string, message: string, meta: any = {}) => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level,
    message,
    ...meta
  }));
};

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  const requestId = context.awsRequestId;
  
  // Log request without sensitive data
  log('INFO', 'Request received', {
    requestId,
    method: event.httpMethod,
    userAgent: event.headers?.['User-Agent'] || event.headers?.['user-agent'],
    hasAuth: !!event.headers?.authorization || !!event.headers?.Authorization,
    bodySize: event.body?.length || 0
  });
  
  // Validate environment variables
  const AUTH = process.env.FLOW_SHARED_SECRET;
  const SLACK = process.env.SLACK_WEBHOOK_URL;
  
  if (!AUTH) {
    log('ERROR', 'FLOW_SHARED_SECRET environment variable not set', { requestId });
    return { statusCode: 500, body: JSON.stringify({ error: 'Internal Server Error' }) };
  }
  
  if (!SLACK) {
    log('ERROR', 'SLACK_WEBHOOK_URL environment variable not set', { requestId });
    return { statusCode: 500, body: JSON.stringify({ error: 'Internal Server Error' }) };
  }
  
  // Validate Bearer token
  const authHdr = (event.headers?.authorization || event.headers?.Authorization || "");
  const providedToken = authHdr.startsWith("Bearer ") ? authHdr.slice(7) : null;
  
  if (!providedToken || providedToken !== AUTH) {
    log('WARN', 'Authentication failed', { 
      requestId,
      hasBearer: authHdr.startsWith("Bearer "),
      authHeaderLength: authHdr.length
    });
    return { statusCode: 401, body: JSON.stringify({ error: 'Unauthorized' }) };
  }
  
  log('INFO', 'Authentication successful', { requestId });
  
  // Parse and validate request body
  let body: any;
  try {
    body = typeof event.body === "string" ? JSON.parse(event.body || "{}") : (event.body || {});
  } catch (error) {
    log('ERROR', 'Invalid JSON in request body', { 
      requestId, 
      error: error instanceof Error ? error.message : String(error)
    });
    return { statusCode: 400, body: JSON.stringify({ error: 'Invalid JSON' }) };
  }
  
  // Validate expected fields
  if (body && typeof body !== 'object') {
    log('ERROR', 'Request body must be an object', { requestId });
    return { statusCode: 400, body: JSON.stringify({ error: 'Request body must be an object' }) };
  }
  
  log('INFO', 'Request body parsed successfully', { 
    requestId,
    hasOrderId: !!body.orderId,
    hasName: !!body.name,
    hasTotal: !!body.total
  });
  
  // Format Slack message
  const text = `📦 New Order: ${body.name || "Unknown"} • $${body.total || "0"} • ID: ${body.orderId || "N/A"}`;
  
  // Post to Slack
  try {
    log('INFO', 'Posting to Slack', { requestId });
    
    const response = await fetch(SLACK, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      log('ERROR', 'Slack API error', {
        requestId,
        status: response.status,
        statusText: response.statusText,
        responseBody: errorText
      });
      return { statusCode: 502, body: JSON.stringify({ error: 'Slack integration failed' }) };
    }
    
    log('INFO', 'Successfully posted to Slack', { 
      requestId,
      slackStatus: response.status 
    });
    
  } catch (error) {
    log('ERROR', 'Slack post failed', {
      requestId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined
    });
    return { statusCode: 502, body: JSON.stringify({ error: 'Slack integration failed' }) };
  }
  
  log('INFO', 'Request completed successfully', { requestId });
  return { 
    statusCode: 200, 
    body: JSON.stringify({ message: 'Success', requestId })
  };
};