# Shared Terragrunt configuration, included by every unit under live/.
locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  # Git-ignored: AWS account ID and admin IP. Copy private.hcl.example to create it.
  private = read_terragrunt_config(find_in_parent_folders("private.hcl")).locals
}

# Terragrunt prefers OpenTofu when it finds it; this state belongs to Terraform.
terraform_binary = "terraform"

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
    provider "aws" {
      region              = "${local.region.aws_region}"
      allowed_account_ids = ["${local.private.aws_account_id}"]
    }
  EOT
}

# The bucket is managed by bootstrap/state, so the backend is plain generated
# HCL rather than a remote_state block Terragrunt might try to bootstrap.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
    terraform {
      backend "s3" {
        bucket              = "${local.env.state_bucket}"
        region              = "${local.env.state_bucket_region}"
        key                 = "${path_relative_to_include()}/terraform.tfstate"
        encrypt             = true
        use_lockfile        = true
        allowed_account_ids = ["${local.private.aws_account_id}"]
      }
    }
  EOT
}

inputs = merge(local.env.shared_inputs, {
  ssh_cidr_blocks      = [local.private.admin_cidr]
  tailscale_cidr_block = local.private.admin_cidr
})
