output "lambda_role" {
  description = "IAM role ARN for Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "IAM role name for Lambda"
  value       = aws_iam_role.lambda_role.name
}