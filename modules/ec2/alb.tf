locals {
  cert_parts = {
    key = "pilgrim.farm-key"
    crt = "pilgrim.farm-crt"
    caf = "pilgrim.farm-caf"
  }
}

###############################################################################
# SECRETS
###############################################################################
data "aws_secretsmanager_secret" "cert" {
  for_each = local.cert_parts
  name     = each.value
}

data "aws_secretsmanager_secret_version" "cert" {
  for_each  = local.cert_parts
  secret_id = data.aws_secretsmanager_secret.cert[each.key].id
}

###############################################################################
# ALB
###############################################################################
resource "aws_acm_certificate" "pg" {
  private_key       = data.aws_secretsmanager_secret_version.cert["key"].secret_string
  certificate_body  = data.aws_secretsmanager_secret_version.cert["crt"].secret_string
  certificate_chain = data.aws_secretsmanager_secret_version.cert["caf"].secret_string

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "pg" {
  name               = "${var.instance_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.aws_subnets.public.ids
  idle_timeout       = 300

  tags = {
    Name = "${var.instance_name}-alb"
  }
}

###############################################################################
# LISTENERS
###############################################################################
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.pg.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.pg.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pg.arn
  }
}

###############################################################################
# TARGET GROUPS
###############################################################################
resource "aws_lb_target_group" "pg" {
  name        = "${var.instance_name}-http"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path     = "/edge-health"
    port     = "traffic-port"
    protocol = "HTTP"
  }
}
