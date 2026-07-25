output "aws_iam_role_policy" {
    description = "Inline policy: lets Lambda invoke a Bedrock Agent"
    value       = aws_iam_role_policy.bedrock_invoke.id
}