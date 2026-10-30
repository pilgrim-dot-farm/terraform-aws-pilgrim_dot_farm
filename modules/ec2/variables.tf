variable "aws_region" {
  default = "us-west-1"
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
  description = "CIDR blocks allowed to reach the instance on ports 80 and 443 (HTTP/HTTPS)"
  type        = list(string)
  default = ["0.0.0.0/0"]
  #default = [
  #  "203.0.113.10/32",
  #  "64.238.204.180/32",
  #  "187.14.81.107/32",
  #  "187.14.96.68/32",
  #  "195.158.249.173/32",
  #  "187.14.98.113/32"
  #]
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks allowed as egress destinations (0.0.0.0/0 = all)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
