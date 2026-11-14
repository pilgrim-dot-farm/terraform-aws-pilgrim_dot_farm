# Shared values; set once in live/<env>/env.hcl.
variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance and related resources"
}

# Wiring from other units.
variable "bucket_arns" {
  description = "Application bucket ARNs by purpose, from the data unit"
  type        = map(string)
}

variable "db_secret_arn" {
  description = "RDS-managed master user secret ARN, from the data unit"
  type        = string
}

variable "stripe_secret_file" {
  description = "Absolute path to the local Stripe credentials JSON file"
  type        = string
}
