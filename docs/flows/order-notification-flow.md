sequenceDiagram
    participant Customer
    participant ShopifyStore as Shopify Store
    participant ShopifyFlow as Shopify Flow
    participant Lambda as Order Notification Handler
    participant CloudWatch as CloudWatch Logs
    participant Slack as Slack Webhook API
    participant SlackChannel as Slack Channel

    Note over Customer, SlackChannel: Shopify Order to Slack Notification Flow

    Customer->>ShopifyStore: Place order<br/>(products, payment, shipping)
    
    Note over ShopifyStore: Order processing:<br/>- Payment validation<br/>- Inventory check<br/>- Order creation
    
    ShopifyStore->>ShopifyFlow: Order created event<br/>{orderId, name, total, customer}
    
    Note over ShopifyFlow: Flow trigger activated:<br/>- "Order created" event detected<br/>- HTTP action configured
    
    ShopifyFlow->>Lambda: POST Function URL<br/>Authorization: Bearer {FLOW_SHARED_SECRET}<br/>Content-Type: application/json<br/>{orderId, name, totalPrice}
    
    Note over Lambda: Request processing begins
    
    Lambda->>CloudWatch: Log request received<br/>{requestId, method, hasAuth, bodySize}
    
    Note over Lambda: Environment validation:<br/>- FLOW_SHARED_SECRET presence<br/>- SLACK_WEBHOOK_URL presence
    
    alt Missing environment variables
        Lambda->>CloudWatch: Log error - Missing env vars<br/>{level: ERROR, message: "Env var not set"}
        Lambda-->>ShopifyFlow: HTTP 500 - Internal Server Error<br/>{"error": "Internal Server Error"}
        Note over ShopifyFlow: Flow shows error status<br/>Will retry based on configuration
    
    else Environment variables present
        Note over Lambda: Authentication validation:<br/>- Extract Bearer token<br/>- Compare with FLOW_SHARED_SECRET
        
        alt Invalid or missing Bearer token
            Lambda->>CloudWatch: Log auth failure<br/>{level: WARN, message: "Authentication failed"}
            Lambda-->>ShopifyFlow: HTTP 401 - Unauthorized<br/>{"error": "Unauthorized"}
            Note over ShopifyFlow: Flow shows authentication error<br/>Check Bearer token configuration
        
        else Valid Bearer token
            Lambda->>CloudWatch: Log auth success<br/>{level: INFO, message: "Authentication successful"}
            
            Note over Lambda: Request body parsing:<br/>- JSON.parse(event.body)<br/>- Validate object structure
            
            alt Invalid JSON or malformed body
                Lambda->>CloudWatch: Log parse error<br/>{level: ERROR, message: "Invalid JSON"}
                Lambda-->>ShopifyFlow: HTTP 400 - Bad Request<br/>{"error": "Invalid JSON"}
                Note over ShopifyFlow: Flow shows data format error
            
            else Valid JSON body
                Lambda->>CloudWatch: Log body parsed<br/>{hasOrderId, hasName, hasTotal}
                
                Note over Lambda: Format Slack message:<br/>"📦 New Order: {name} • ${total} • ID: {orderId}"
                
                Lambda->>CloudWatch: Log Slack posting<br/>{level: INFO, message: "Posting to Slack"}
                
                Lambda->>Slack: POST webhook URL<br/>Content-Type: application/json<br/>{"text": formatted_message}
                
                alt Slack webhook error
                    Slack-->>Lambda: HTTP 4xx/5xx error<br/>Error response body
                    Lambda->>CloudWatch: Log Slack error<br/>{level: ERROR, status, responseBody}
                    Lambda-->>ShopifyFlow: HTTP 502 - Bad Gateway<br/>{"error": "Slack integration failed"}
                    Note over ShopifyFlow: Flow shows external service error
                
                else Slack webhook success
                    Slack-->>Lambda: HTTP 200 OK
                    Lambda->>CloudWatch: Log Slack success<br/>{level: INFO, slackStatus: 200}
                    
                    Slack->>SlackChannel: Display notification<br/>"📦 New Order: #1002 • $100.0 • ID: gid://shopify/Order/123"
                    
                    Lambda->>CloudWatch: Log request complete<br/>{level: INFO, message: "Request completed successfully"}
                    Lambda-->>ShopifyFlow: HTTP 200 OK<br/>{"message": "Success", "requestId": requestId}
                    
                    Note over ShopifyFlow: Flow shows success status<br/>Order notification complete
                end
            end
        end
    end

    Note over Customer, SlackChannel: Order Notification Process Complete

    Note over SlackChannel: Team receives real-time notification<br/>Order details immediately available

    Note over Customer, SlackChannel: Error Handling and Security Notes
    
    Note over Lambda: Security measures implemented:<br/>- Bearer token authentication<br/>- Environment variable validation<br/>- Request sanitization<br/>- No sensitive data logging<br/>- Structured logging with correlation IDs
    
    Note over CloudWatch: Monitoring and debugging:<br/>- All requests logged with unique IDs<br/>- Error scenarios captured<br/>- Performance metrics available<br/>- Log retention: 1 week<br/>- Logs encrypted with KMS

    Note over ShopifyFlow: Flow configuration requirements:<br/>- Function URL as endpoint<br/>- Bearer token in Authorization header<br/>- JSON request body with order variables<br/>- Retry logic for failed requests

    Note over Slack: Webhook integration:<br/>- Incoming webhook configured<br/>- Channel-specific notifications<br/>- Message formatting for readability<br/>- Error responses logged for debugging