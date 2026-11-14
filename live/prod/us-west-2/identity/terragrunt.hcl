include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/identity"
}

dependency "data" {
  config_path = "../data"
}

inputs = {
  bucket_arns   = dependency.data.outputs.bucket_arns
  db_secret_arn = dependency.data.outputs.db_master_user_secret_arn

  # Git-ignored; never copied into the Terragrunt cache.
  stripe_secret_file = "${get_repo_root()}/secrets/prod/stripe.json"
}
