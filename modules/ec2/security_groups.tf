locals {
  front_end_sg_ids = [
    aws_security_group.pg.id,
    aws_security_group.cache.id,
    aws_security_group.db.id
  ]
}
###############################################################################
# EC2
###############################################################################
resource "aws_security_group" "pg" {
  name        = "${var.instance_name}-ec2"
  description = "Security group for the ${var.instance_name} EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.instance_name}-ec2"
  }
}

# Admin SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = length(var.ssh_cidr_blocks)
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = var.ssh_cidr_blocks[count.index]
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP from ALB to Fargate tasks using the shared front-end security group.
resource "aws_vpc_security_group_ingress_rule" "alb_ec2" {
  security_group_id            = aws_security_group.pg.id
  referenced_security_group_id = aws_security_group.lb.id
  from_port                    = var.ecs_container_port
  to_port                      = var.ecs_container_port
  ip_protocol                  = "tcp"
}

# LiteLLM relay on the bastion (SCALABILITY.md Step 5 addendum): the Fargate
# tasks carry this same group, so admit :4000 from itself.
resource "aws_vpc_security_group_ingress_rule" "litellm_relay" {
  security_group_id            = aws_security_group.pg.id
  referenced_security_group_id = aws_security_group.pg.id
  from_port                    = 4000
  to_port                      = 4000
  ip_protocol                  = "tcp"
}

# Tailscale
resource "aws_vpc_security_group_ingress_rule" "ts" {
  security_group_id = aws_security_group.pg.id
  cidr_ipv4         = "203.0.113.10/32"
  from_port         = 41641
  to_port           = 41641
  ip_protocol       = "udp"
}


###############################################################################
# ALB
###############################################################################
resource "aws_security_group" "lb" {
  name        = "${var.instance_name}-alb"
  description = "Security group for the ALB"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.instance_name}-ec2"
  }
}

# Cloudflare HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  count             = length(var.web_cidr_blocks)
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = var.web_cidr_blocks[count.index]
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Cloudflare HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  count             = length(var.web_cidr_blocks)
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = var.web_cidr_blocks[count.index]
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

###############################################################################
# ELASTICACHE
###############################################################################
resource "aws_security_group" "cache" {
  name        = "${var.instance_name}-cache"
  description = "Valkey access from the EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.instance_name}-cache"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cache" {
  security_group_id            = aws_security_group.cache.id
  referenced_security_group_id = aws_security_group.pg.id
  from_port                    = var.cache_port
  to_port                      = var.cache_port
  ip_protocol                  = "tcp"
}

###############################################################################
# RDS
###############################################################################
resource "aws_security_group" "db" {
  name        = "${var.instance_name}-db"
  description = "PostgreSQL access"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.instance_name}-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.pg.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

###############################################################################
# COMMON
###############################################################################
resource "aws_vpc_security_group_egress_rule" "all_tcp" {
  for_each = {
    ec2 = aws_security_group.pg.id
    alb = aws_security_group.lb.id
  }

  security_group_id = each.value
  cidr_ipv4         = var.egress_cidr_blocks[0]
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_udp" {
  for_each = {
    ec2 = aws_security_group.pg.id
    alb = aws_security_group.lb.id
  }

  security_group_id = each.value
  cidr_ipv4         = var.egress_cidr_blocks[0]
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "udp"
}
