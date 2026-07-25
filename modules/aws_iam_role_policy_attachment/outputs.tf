output "attach_role_policy" {
  description = "Attach basic Lambda logging permissions"
  value       = aws_iam_role_policy_attachment.lambda_logging_permissions
}