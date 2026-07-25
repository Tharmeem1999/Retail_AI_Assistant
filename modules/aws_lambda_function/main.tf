data "archive_file" "chat_lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/chat.zip"

  # Makes ZIP metadata more consistent across machines.
  output_file_mode = "0644"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn
  runtime       = var.runtime
  handler       = var.handler

  filename         = data.archive_file.chat_lambda.output_path
  source_code_hash = data.archive_file.chat_lambda.output_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = {
      AGENT_ID       = var.agent_id
      AGENT_ALIAS_ID = var.agent_alias_id
    }
  }
}