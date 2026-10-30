resource "aws_security_group" "pg" {
  name        = "${var.instance_name}-ec2"
  description = "Security group for the ${var.instance_name} EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.instance_name}-ec2"
  }
}

# Only allow SSH (22) from the configured public IP(s).
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = length(var.ssh_cidr_blocks)
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = var.ssh_cidr_blocks[count.index]
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Allow HTTPS (443) and HTTP (80) from our public IP and the approved partner IPs.
resource "aws_vpc_security_group_ingress_rule" "https" {
  count             = length(var.web_cidr_blocks)
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = var.web_cidr_blocks[count.index]
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  count             = length(var.web_cidr_blocks)
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = var.web_cidr_blocks[count.index]
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow outbound TCP to 0.0.0.0/0.
resource "aws_vpc_security_group_egress_rule" "all_tcp" {
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = var.egress_cidr_blocks[0]
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}
