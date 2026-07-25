# Serverless Retail AI Assistant on AWS Bedrock

A fully serverless, Infrastructure-as-Code retail website with an embedded AI chatbot. Product catalog questions are answered by an **Amazon Bedrock Agent** powered by **Amazon Nova Pro**, backed by an **OpenSearch Serverless** vector store as a RAG knowledge base. The frontend is a static website served locally, and the chatbot communicates with the agent through a **Lambda + API Gateway** backend — all provisioned with Terraform.

---

## Overview

This project deploys a complete retail AI assistant from scratch using Terraform. It includes:

- A **static website** with a home page (product categories) and category pages (product details).
- A **floating chatbot widget** on every page that lets customers ask questions about products.
- A **Bedrock Agent** grounded in `product_inventory.csv` via a RAG knowledge base, so it answers questions about availability, pricing, and features without hallucinating.

**How it works (end-to-end):**

1. The CSV catalog is uploaded to an S3 bucket.
2. A Bedrock **Knowledge Base** (vector store in OpenSearch Serverless) ingests and indexes the catalog using the `amazon.titan-embed-text-v2` embedding model.
3. A Bedrock **Agent** is created with a strict system prompt (`instructions.txt`) that forbids guessing and requires referencing the inventory file.
4. The Agent is associated with the Knowledge Base, enabling RAG lookups on every user turn.
5. The static website is opened locally (e.g. via Live Server). The chatbot widget sends messages to an **API Gateway HTTP API**.
6. API Gateway proxies requests to a **Lambda function** (`chat.py`) which calls the Bedrock Agent runtime and streams the response back to the browser.

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| **IaC** | Terraform ≥ 1.5 |
| **Cloud** | AWS (`us-east-1`) |
| **AI Orchestration** | Amazon Bedrock Agent |
| **Foundation Model** | Amazon Nova Pro (`amazon.nova-pro-v1:0`) |
| **Embedding Model** | Amazon Titan Text Embeddings v2 (`amazon.titan-embed-text-v2:0`) |
| **Vector Store** | Amazon OpenSearch Serverless (Vector Search collection) |
| **Storage** | Amazon S3 (catalog source documents) |
| **Chat API** | AWS Lambda (Python 3.12) + API Gateway HTTP API |
| **AuthN/AuthZ** | IAM roles with least-privilege inline policies |
| **Memory** | Bedrock Agent session-summary memory (30 days) |
| **Frontend** | Vanilla HTML, CSS, JavaScript (static, no framework) |
| **Providers** | `hashicorp/aws` 6.47.0, `hashicorp/time` ~0.11, `hashicorp/null` ~3.0 |

---

## Project Structure

```text
Retail_AI_Assistant/
├── main.tf                          # Root module: wires every submodule together
├── provider.tf                      # AWS provider + required providers declaration
├── variables.tf                     # Root input variables
├── instructions.txt                 # System prompt that governs agent behavior
├── product_inventory.csv            # Source catalog ingested into the knowledge base
├── website/                         # Static frontend
│   ├── index.html                   # Home page — product category cards
│   ├── category.html                # Product listing page for a selected category
│   ├── products.js                  # Shared product data (parsed from CSV)
│   ├── chatbot.js                   # Chatbot widget — calls API Gateway
│   ├── style.css                    # Shared styles
│   ├── README.md                    # Website-specific deployment notes
│   └── api/
│       └── chat.py                  # Lambda handler — proxies to Bedrock Agent runtime
└── modules/
    ├── bedrock_agent/               # Bedrock Agent + IAM role + permissions
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf               # → agent_id
    ├── aws_bedrockagent_knowledge_base/   # KB + OpenSearch Serverless + index bootstrap
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf               # → knowledge_base_id
    │   └── versions.tf
    ├── aws_bedrockagent_data_source/      # S3-backed data source + ingestion job trigger
    │   ├── main.tf
    │   ├── variables.tf
    │   └── versions.tf
    ├── s3_bucket/                   # Bucket that hosts the catalog
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf               # → bucket_arn
    ├── s3_bucket_object/            # Uploads product_inventory.csv into the bucket
    │   ├── main.tf
    │   └── variables.tf
    ├── aws_lambda_function/         # Lambda function (chat.py) + auto-zip via archive_file
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf               # → function_name, function_arn, invoke_arn
    ├── aws_apigatewayv2_http_api/   # HTTP API + Lambda integration + POST & OPTIONS routes
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf               # → chat_url
    ├── aws_iam_role/                # IAM execution role for Lambda
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf                # → lambda_role (ARN), lambda_role_name
    ├── aws_iam_role_policy/         # Inline policy: bedrock:InvokeAgent
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── aws_iam_role_policy_attachment/    # Attaches AWSLambdaBasicExecutionRole
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Prerequisites

- **AWS Account** with permissions to create Bedrock Agents, Knowledge Bases, OpenSearch Serverless collections, S3 buckets, Lambda functions, API Gateway APIs, and IAM roles.
- **Model access enabled** in Amazon Bedrock (`us-east-1`):
  - `amazon.nova-pro-v1:0`
  - `amazon.titan-embed-text-v2:0`
  > Enable from AWS Console → *Amazon Bedrock → Model access*.
- **AWS CLI** configured (`aws configure`) with credentials for `bedrock-agent`, `s3`, `iam`, `lambda`, `apigateway`, and `aoss`.
- **awscurl** — used to pre-create the OpenSearch vector index:
  ```bash
  pip install awscurl
  ```
- **Terraform** ≥ 1.5:
  ```bash
  terraform -version
  ```

---

## Configuration

Variables defined in `variables.tf`:

| Variable | Default | Description |
| --- | --- | --- |
| `chatbot_name` | `chatbot-agent` | Base name for the Bedrock agent and S3 bucket |
| `chatbot_foundation_model` | `amazon.nova-pro-v1:0` | Bedrock foundation model ID |
| `knowledge_base_name` | `shop-inventory-kb` | Name of the Knowledge Base and OpenSearch collection |
| `data_source_name` | `inventory-s3-data-source` | Name of the S3-backed data source |
| `lambda_role` | `shopai-lambda-role` | IAM role name for the Lambda function |
| `role_policy_name` | `bedrock-invoke` | Name of the inline policy granting `bedrock:InvokeAgent` |
| `website_origin` | `http://127.0.0.1:5500` | Origin allowed by API Gateway CORS (match your Live Server port) |
| `bedrock_agent_alias_id` | `TSTALIASID` | Bedrock Agent alias ID used by the Lambda |
| `aws_region` | `us-east-1` | AWS region |

Override any variable by creating a `terraform.tfvars` file:

```hcl
chatbot_name             = "my-shop-bot"
knowledge_base_name      = "shop-inventory-kb"
website_origin           = "http://127.0.0.1:5500"
bedrock_agent_alias_id   = "TSTALIASID"
```

---

## How to Deploy

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tharmeem1999/chat-bot-agent.git
   cd chat-bot-agent
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review the execution plan**
   ```bash
   terraform plan
   ```

4. **Apply the configuration**
   ```bash
   terraform apply
   ```

   Resources are created in this order:
   1. S3 bucket + `product_inventory.csv` upload.
   2. OpenSearch Serverless encryption, network, and data-access policies.
   3. OpenSearch Serverless vector collection + `bedrock-knowledge-base-default-index` (via `awscurl`).
   4. Bedrock Knowledge Base.
   5. S3 data source + automatic ingestion job.
   6. Bedrock Agent + IAM role.
   7. Knowledge-base ↔ agent association.
   8. Lambda IAM role + policy attachment + inline `bedrock:InvokeAgent` policy.
   9. Lambda function (`shopai-chat`) — `chat.py` is auto-zipped by Terraform.
   10. API Gateway HTTP API with `POST /chat` and `OPTIONS /chat` routes.

5. **Inspect outputs**
   ```bash
   terraform output
   ```
   You should see:
   - `agent_id`
   - `knowledge_base_id`
   - `bucket_arn`
   - `chat_api_url` — the full URL for the chatbot API (`https://<id>.execute-api.us-east-1.amazonaws.com/prod/chat`)
   - `lambda_function_name`

6. **Open the website**

   Open `website/index.html` with **Live Server** (VS Code extension) or any local HTTP server. The chatbot widget in the bottom-right corner will connect to the deployed API automatically.

   > Make sure `website_origin` in `variables.tf` matches the origin your Live Server uses (default: `http://127.0.0.1:5500`). If it differs, update the variable and re-run `terraform apply`.

---

## Website

The frontend is a pure HTML/CSS/JS static site — no build step required.

| Page | File | Description |
| --- | --- | --- |
| Home | `index.html` | Displays all product categories as clickable cards |
| Category | `category.html` | Lists all products in the selected category with price, availability badge, features, description, and stock count |

The chatbot widget (`chatbot.js`) is included on every page. It:
- Generates a random `session_id` per browser session so conversation memory is maintained.
- Sends `POST` requests to the API Gateway endpoint.
- Displays a greeting on first open and shows a "Thinking…" indicator while waiting for a response.

---

## Chatbot Backend

```
Browser → API Gateway (POST /chat) → Lambda (chat.py) → Bedrock Agent runtime → Nova Pro + Knowledge Base
```

- **CORS** is handled entirely by the Lambda (not API Gateway), returning `Access-Control-Allow-Origin: *` on every response including OPTIONS preflight requests.
- The Lambda uses **payload format version 2.0**, reading the HTTP method from `event["requestContext"]["http"]["method"]`.
- The Bedrock Agent streams its response in chunks; the Lambda concatenates them before returning.

---

## Updating the Catalog

1. Edit `product_inventory.csv`.
2. Re-upload to S3:
   ```bash
   aws s3 cp product_inventory.csv s3://chatbot-agent-files/product_inventory.csv
   ```
3. Trigger a fresh ingestion job:
   ```bash
   aws bedrock-agent start-ingestion-job \
     --knowledge-base-id $(terraform output -raw knowledge_base_id) \
     --data-source-id <DATA_SOURCE_ID> \
     --region us-east-1
   ```
4. Also update the `products` array in `website/products.js` so the website reflects the new catalog.

---

## Customizing the Agent

- **Behavior / persona:** edit `instructions.txt`.
- **Foundation model:** change `chatbot_foundation_model` in `terraform.tfvars`.
- **Memory:** session-summary memory with 30-day retention is configured in the `bedrock_agent` module.

---

## Cleanup

```bash
terraform destroy -auto-approve
```

> OpenSearch Serverless collections take a few minutes to delete.
