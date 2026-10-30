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
