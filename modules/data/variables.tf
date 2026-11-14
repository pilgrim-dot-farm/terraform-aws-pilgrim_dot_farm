# Shared values; set once in live/<env>/env.hcl.
variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance and related resources"
}

variable "db_port" {
  type = number
}

# Unit settings.
variable "cache_ecpu_per_second" {
  default = 25000
}

# Wiring from other units.
variable "private_subnet_ids" {
  description = "Private subnet IDs from the network unit"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Database security group ID from the network unit"
  type        = string
}

variable "cache_security_group_id" {
  description = "Cache security group ID from the network unit"
  type        = string
}
