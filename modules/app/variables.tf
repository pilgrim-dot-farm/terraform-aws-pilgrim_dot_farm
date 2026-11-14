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

# Unit settings.
variable "ami_id" {
  default = "ami-09f02015912e773f7"
}

variable "key_name" {
  default = "pg"
}

variable "instance_type" {
  default = "c7i-flex.large"
}

variable "disk_size" {
  description = "Root volume size in GB"
  default     = 32
}

variable "ecs_count" {
  description = "Initial desired task count; autoscaling manages the running count within 1 to 5 tasks."
  type        = number
  default     = 1
}

variable "ecs_container_image" {
  description = "Application image URI (Linux x86_64). Leave null to create only the ECS cluster until the image is ready."
  type        = string
  default     = "pilgrimdotfarm/front-end:latest"
}

variable "ecs_release" {
  description = "Change this value to create a new task definition revision and redeploy the current image tag."
  type        = string
  default     = "27"
}

variable "ecs_cpu_target_percent" {
  default = 60
}

variable "ecs_cpu_memory_percent" {
  default = 75
}

# Wiring from other units.
variable "vpc_id" {
  description = "VPC ID from the network unit"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB, from the network unit"
  type        = list(string)
}

variable "ec2_subnet_id" {
  description = "Public subnet for the EC2 instance, from the network unit"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (routing complete) from the network unit"
  type        = list(string)
}

variable "front_end_sg_ids" {
  description = "Ordered app, cache and database security group IDs from the network unit"
  type        = list(string)
}

variable "lb_security_group_id" {
  description = "ALB security group ID from the network unit"
  type        = string
}

variable "db_endpoint" {
  description = "PostgreSQL host:port from the data unit"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name from the data unit"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username from the data unit"
  type        = string
}

variable "db_secret_arn" {
  description = "RDS-managed master user secret ARN from the data unit"
  type        = string
}

variable "cache_url" {
  description = "TLS Valkey URL from the data unit"
  type        = string
}

variable "stripe_secret_arn" {
  description = "Stripe secret ARN from the identity unit"
  type        = string
}

variable "app_role_arn" {
  description = "Application IAM role ARN from the identity unit"
  type        = string
}

variable "instance_profile_name" {
  description = "EC2 instance profile name from the identity unit"
  type        = string
}
