# ShopAI Website

## Structure
```
website/
├── index.html      # Home page — category cards
├── category.html   # Product listing for a selected category
├── products.js     # Shared product data
├── chatbot.js      # Chatbot widget (calls API Gateway → Lambda → Bedrock Agent)
├── style.css       # Shared styles
└── api/
    └── chat.py     # Lambda handler
```

## Running locally (no backend)
Just open `index.html` in a browser. The chatbot widget will show but API calls
will fail until you deploy the Lambda and set `CHAT_API_URL` in `chatbot.js`.

## Deploying the chatbot backend

### 1 — Package and deploy the Lambda
```bash
cd website/api
zip chat.zip chat.py

aws lambda create-function \
  --function-name shopai-chat \
  --runtime python3.12 \
  --handler chat.handler \
  --zip-file fileb://chat.zip \
  --role arn:aws:iam::<ACCOUNT_ID>:role/<LAMBDA_EXEC_ROLE> \
  --environment "Variables={AGENT_ID=<your_agent_id>,AGENT_ALIAS_ID=TSTALIASID}" \
  --region us-east-1
```

The Lambda execution role needs:
- `bedrock:InvokeAgent` on your agent ARN

### 2 — Create an API Gateway (HTTP API)
```bash
# Create the API
aws apigatewayv2 create-api \
  --name shopai-api \
  --protocol-type HTTP \
  --cors-configuration \
    AllowOrigins='["*"]',AllowMethods='["POST","OPTIONS"]',AllowHeaders='["Content-Type"]' \
  --region us-east-1

# Add Lambda integration + route POST /chat, then deploy to a stage named "prod"
```
Or use the AWS Console: API Gateway → Create HTTP API → Add Lambda integration →
add route `POST /chat` → deploy to stage `prod`.

### 3 — Update chatbot.js
Replace `YOUR_API_GATEWAY_URL` in `chatbot.js` with your invoke URL:
```js
const CHAT_API_URL = "https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/chat";
```

### 4 — Host the frontend
Upload the four frontend files to S3 with static website hosting, or serve them
from any web server / CDN:
```bash
aws s3 sync website/ s3://<your-website-bucket>/ \
  --exclude "api/*" \
  --acl public-read
```
