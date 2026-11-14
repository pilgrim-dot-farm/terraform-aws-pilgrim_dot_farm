include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/app"
}

dependency "network" {
  config_path = "../network"
}

dependency "data" {
  config_path = "../data"
}

dependency "identity" {
  config_path = "../identity"
}

inputs = {
  # Release controls: bump ecs_release to redeploy an image published under the same tag.
  ecs_container_image = "pilgrimdotfarm/front-end:latest"
  ecs_release         = "27"
  ecs_count           = 1

  vpc_id               = dependency.network.outputs.vpc_id
  public_subnet_ids    = dependency.network.outputs.public_subnet_ids
  ec2_subnet_id        = dependency.network.outputs.ec2_subnet_id
  private_subnet_ids   = dependency.network.outputs.private_subnet_ids
  front_end_sg_ids     = dependency.network.outputs.front_end_sg_ids
  lb_security_group_id = dependency.network.outputs.lb_security_group_id

  db_endpoint   = dependency.data.outputs.db_endpoint
  db_name       = dependency.data.outputs.db_name
  db_username   = dependency.data.outputs.db_username
  db_secret_arn = dependency.data.outputs.db_master_user_secret_arn
  cache_url     = dependency.data.outputs.cache_url

  stripe_secret_arn     = dependency.identity.outputs.stripe_secret_arn
  app_role_arn          = dependency.identity.outputs.app_role_arn
  instance_profile_name = dependency.identity.outputs.instance_profile_name
}
