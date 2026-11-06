variable "aws_region" {
  default = "us-west-1"
}

variable "ami_id" {
  default = "ami-0151cebd38515a41d"
}

variable "key_name" {
  default = "pg"
}

variable "domain_name" {
  default = "pilgrim.farm"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance and related resources"
  default     = "pg"
}

variable "instance_type" {
  default = "c7i-flex.large"
}

variable "disk_size" {
  description = "Root volume size in GB"
  default     = 32
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the instance (port 22)"
  type        = list(string)
  default     = ["203.0.113.10/32"]
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

variable "cache_port" {
  default = 6379
}

variable "db_port" {
  default = 5432
}

variable "ecs_count" {
  default = 1
}

variable "ecs_container_image" {
  description = "Application image URI (Linux x86_64). Leave null to create only the ECS cluster until the image is ready."
  type        = string
  default     = "pilgrimdotfarm/front-end:latest"
}

variable "ecs_container_port" {
  description = "Port the application container listens on; the existing security group allows 8080 from the ALB."
  type        = number
  default     = 8080

  validation {
    condition     = var.ecs_container_port >= 1 && var.ecs_container_port <= 65535 && floor(var.ecs_container_port) == var.ecs_container_port
    error_message = "ecs_container_port must be an integer between 1 and 65535."
  }
}
