resource "aws_iam_role_policy" "bedrock_invoke" {
  name = var.role_policy_name
  role = var.policy_role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeAgent"]
      Resource = "*"
    }]
  })
}