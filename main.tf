# --- Bedrock Agent ---
module "bedrock_agent" {
  source = "./modules/bedrock_agent"

  agent_name = "${var.chatbot_name}"
  foundation_model = "${var.chatbot_foundation_model}"
  instruction = file("${path.module}/instructions.txt")
}

# --- S3 Bucket ---
module "s3_bucket" {
  source = "./modules/s3_bucket"
  
  bucket_name = "${var.chatbot_name}-files"
}


# --- S3 Bucket Object ---
module "s3_bucket_object" {
  source = "./modules/s3_bucket_object"

  bucket_name   = "${var.chatbot_name}-files"
  bucket_key    = "product_inventory.csv"
  bucket_source = "${path.module}/product_inventory.csv"

  depends_on = [module.s3_bucket]
}


# --- Bedrock Agent Knowledge Base ---
module "bedrockagent_knowledge_base" {
  source      = "./modules/aws_bedrockagent_knowledge_base"
  name_kb     = var.knowledge_base_name
  bucket_name = "${var.chatbot_name}-files"
}


# --- Bedrock Agent Data Source ---
module "bedrockagent_data_source" {
  source = "./modules/aws_bedrockagent_data_source"
  name_ds           = var.data_source_name
  knowledge_base_id = module.bedrockagent_knowledge_base.knowledge_base_id
  bucket_arn        = module.s3_bucket.bucket_arn
}


# --- Associate Agent with Knowledge Base ---
resource "aws_bedrockagent_agent_knowledge_base_association" "inventory" {
  agent_id             = module.bedrock_agent.agent_id
  knowledge_base_id    = module.bedrockagent_knowledge_base.knowledge_base_id
  description          = "Product inventory knowledge base"
  knowledge_base_state = "ENABLED"
}


# --- IAM Lambda Role ---
module "iam_role" {
  source = "./modules/aws_iam_role"

  iam_role_name = "${var.lambda_role}"
}


# --- IAM role policy attachment ---
module "iam_role_policy_attachment" {
  source = "./modules/aws_iam_role_policy_attachment"

  lambda_role_name = module.iam_role.lambda_role_name
  policy_arn       = var.attach_role_policy-lambda
}


# --- IAM role policy ----
module "iam_role_policy" {
  source = "./modules/aws_iam_role_policy"

  role_policy_name = var.role_policy_name
  policy_role      = module.iam_role.lambda_role_name
}


module "shopai_chat_lambda" {
  source = "./modules/aws_lambda_function"

  function_name = "shopai-chat"
  role_arn      = module.iam_role.lambda_role

  source_file = "${path.root}/website/api/chat.py"

  agent_id       = module.bedrock_agent.agent_id
  agent_alias_id = var.bedrock_agent_alias_id

  runtime     = "python3.12"
  handler     = "chat.handler"
  timeout     = 30
  memory_size = 256
}

module "shopai_chat_api" {
  source = "./modules/aws_apigatewayv2_http_api"

  api_name              = "shopai-chat-api"
  lambda_invoke_arn     = module.shopai_chat_lambda.invoke_arn
  lambda_function_name  = module.shopai_chat_lambda.function_name
  website_origin        = var.website_origin
  stage_name            = "prod"
}