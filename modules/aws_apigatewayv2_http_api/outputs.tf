output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "chat_url" {
  value = "${aws_apigatewayv2_stage.prod.invoke_url}/chat"
}