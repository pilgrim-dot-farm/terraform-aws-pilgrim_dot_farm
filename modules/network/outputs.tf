output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs in the default VPC, in API order"
  value       = data.aws_subnets.public.ids
}

output "ec2_subnet_id" {
  description = "Public subnet the EC2 instance lives in"
  value       = data.aws_subnet.public[0].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, available once NAT routing is associated"
  value       = local.private_subnet_ids
  depends_on  = [aws_route_table_association.private]
}

output "security_group_id" {
  description = "Application (EC2/Fargate) security group ID"
  value       = aws_security_group.pg.id
}

output "front_end_sg_ids" {
  description = "Ordered application, cache and database security group IDs"
  value       = local.front_end_sg_ids
}

output "lb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.lb.id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "cache_security_group_id" {
  description = "Cache security group ID"
  value       = aws_security_group.cache.id
}
