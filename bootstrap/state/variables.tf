variable "aws_region" {
  description = "Region for the Terraform state bucket"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "Account the state bucket must be created in"
  type        = string
}

variable "bucket_name" {
  description = "Terraform state bucket name"
  type        = string
  default     = "pilgrim-dot-farm-tfstate"
}
