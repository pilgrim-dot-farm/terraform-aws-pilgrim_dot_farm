output "s3_bucket_names" {
  description = "S3 bucket names by purpose"
  value       = { for purpose, bucket in aws_s3_bucket.pilgrim : purpose => bucket.id }
}

output "bucket_arns" {
  description = "S3 bucket ARNs by purpose"
  value       = { for purpose, bucket in aws_s3_bucket.pilgrim : purpose => bucket.arn }
}

output "public_assets_url" {
  description = "Anonymous HTTPS base URL for public objects"
  value       = "https://${aws_cloudfront_distribution.public.domain_name}"
}

output "public_assets_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = aws_cloudfront_distribution.public.id
}

output "db_endpoint" {
  description = "Private PostgreSQL host:port, reachable from the EC2 instance"
  value       = aws_db_instance.db.endpoint
}

output "db_name" {
  description = "Initial PostgreSQL database name"
  value       = aws_db_instance.db.db_name
}

output "db_username" {
  description = "PostgreSQL master username"
  value       = aws_db_instance.db.username
}

output "db_master_user_secret_arn" {
  description = "Secrets Manager secret containing the RDS-managed login credentials"
  value       = local.db_secret_arn
}

output "cache_url" {
  description = "TLS Valkey URL, reachable from the EC2 instance"
  value       = local.redis_url
}
