output "chat_api_url" {
  description = "Paste this URL into website chatbot.js"
  value       = module.shopai_chat_api.chat_url
}

output "lambda_function_name" {
  value = module.shopai_chat_lambda.function_name
}