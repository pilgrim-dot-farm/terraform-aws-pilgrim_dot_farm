locals {
  state_bucket        = "pilgrim-dot-farm-tfstate"
  state_bucket_region = "us-west-2"

  # Values more than one unit needs. Each unit ignores the ones it doesn't declare.
  shared_inputs = {
    instance_name      = "pg"
    db_port            = 5432
    cache_port         = 6379
    ecs_container_port = 8080
    ecs_metrics_port   = 9102
  }
}
