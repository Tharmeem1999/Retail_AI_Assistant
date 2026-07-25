variable "chatbot_name" {
  default = "chatbot-agent"
  type = string
}

variable "chatbot_foundation_model" {
  default = "amazon.nova-pro-v1:0"
  type = string
}

variable "knowledge_base_name" {
  default = "shop-inventory-kb"
}

variable "data_source_name" {
  default = "inventory-s3-data-source"
}

variable "lambda_role" {
  default = "shopai-lambda-role" 
}

variable "attach_role_policy-lambda" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "role_policy_name" {
  default = "bedrock-invoke"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "website_origin" {
  type        = string
  description = "Frontend URL permitted to call the chat API"
  default = "http://127.0.0.1:5500"
}

variable "bedrock_agent_alias_id" {
  type        = string
  description = "Existing Bedrock Agent alias ID, e.g. TSTALIASID"
  default = "TSTALIASID"
}