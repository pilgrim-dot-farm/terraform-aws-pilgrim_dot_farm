include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/data"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  private_subnet_ids      = dependency.network.outputs.private_subnet_ids
  db_security_group_id    = dependency.network.outputs.db_security_group_id
  cache_security_group_id = dependency.network.outputs.cache_security_group_id
}
