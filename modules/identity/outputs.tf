output "app_role_arn" {
  description = "Application IAM role ARN (EC2 instance and ECS task role)"
  value       = local.pg_role_arn
}

output "instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.pg.name
}

output "stripe_secret_arn" {
  description = "Stripe secret ARN, available once its version is written"
  value       = aws_secretsmanager_secret.stripe.arn
  depends_on  = [aws_secretsmanager_secret_version.stripe]
}

output "mac_studio_user_arn" {
  description = "IAM user with read/write access to both buckets"
  value       = aws_iam_user.mac_studio.arn
}
