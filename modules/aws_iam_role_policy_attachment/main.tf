resource "aws_iam_role_policy_attachment" "lambda_logging_permissions" {
  role = var.lambda_role_name
  policy_arn = var.policy_arn
}