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

output "ssh_command" {
  description = "Command to SSH into the instance via the Elastic IP"
  value       = "ssh -i ~/.ssh/pilgrim.farm ec2-user@${aws_eip.pg.public_ip}"
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.pg.arn
}
