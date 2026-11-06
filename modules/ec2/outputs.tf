output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.pg.id
}

output "instance_public_ip" {
  description = "Public IP assigned to the instance at launch"
  value       = aws_instance.pg.public_ip
}

output "elastic_ip" {
  description = "Elastic (static) IP associated with the instance"
  value       = aws_eip.pg.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.pg.id
}

output "ssh_command" {
  description = "Command to SSH into the instance via the Elastic IP"
  value       = "ssh -i ~/.ssh/pilgrim.farm ec2-user@${aws_eip.pg.public_ip}"
}
output "s3_bucket_names" {
  description = "S3 bucket names by purpose"
  value       = { for purpose, bucket in aws_s3_bucket.pilgrim : purpose => bucket.id }
}

output "public_assets_url" {
  description = "Anonymous HTTPS base URL for public objects"
  value       = "https://${aws_cloudfront_distribution.public.domain_name}"
}

output "public_assets_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = aws_cloudfront_distribution.public.id
}

output "mac_studio_user_arn" {
  description = "IAM user with read/write access to both buckets"
  value       = aws_iam_user.mac_studio.arn
}

output "db_endpoint" {
  description = "Private PostgreSQL host:port, reachable from the EC2 instance"
  value       = aws_db_instance.db.endpoint
}

output "db_name" {
  description = "Initial PostgreSQL database name"
  value       = aws_db_instance.db.db_name
}

output "db_master_user_secret_arn" {
  description = "Secrets Manager secret containing the RDS-managed login credentials"
  value       = local.db_secret_arn
}

output "cache_url" {
  description = "TLS Valkey URL, reachable from the EC2 instance"
  value       = local.redis_url
}

#output "ecs_cluster_arn" {
#  description = "ARN of the Fargate ECS cluster"
#  value       = module.ecs.cluster_arn
#}
#
#output "ecs_service_name" {
#  description = "Application ECS service name, or null until an image is configured"
#  value       = try(module.ecs.services["app"].name, null)
#}
