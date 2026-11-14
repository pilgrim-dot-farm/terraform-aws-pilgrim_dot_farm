# Shared values; set once in live/<env>/env.hcl.
variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance and related resources"
}

variable "ecs_container_port" {
  description = "Port the application container listens on; the existing security group allows 8080 from the ALB."
  type        = number
}

variable "ecs_metrics_port" {
  description = "Prometheus /metrics listener in the web container. Never registered with the ALB."
  type        = number
}

variable "cache_port" {
  type = number
}

variable "db_port" {
  type = number
}

# Unit settings.
variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the instance (port 22)"
  type        = list(string)
}

variable "tailscale_cidr_block" {
  description = "CIDR block allowed to reach Tailscale (UDP 41641) on the instance"
  type        = string
}

variable "web_cidr_blocks" {
  description = "Cloudflare proxy CIDR blocks allowed to reach the instance on ports 80 and 443 (HTTP/HTTPS)"
  type        = list(string)
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22"
  ]
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks allowed as egress destinations (0.0.0.0/0 = all)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
