locals {
  redis_url = "rediss://${aws_elasticache_serverless_cache.cache.endpoint[0].address}:${aws_elasticache_serverless_cache.cache.endpoint[0].port}"
}

resource "aws_elasticache_serverless_cache" "cache" {
  name                 = "${var.instance_name}-cache"
  description          = "Serverless Valkey cache for ${var.instance_name}"
  engine               = "valkey"
  major_engine_version = "9"

  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.cache.id]

  snapshot_retention_limit = 0

  cache_usage_limits {
    data_storage {
      maximum = 5
      unit    = "GB"
    }

    ecpu_per_second {
      maximum = 1000
    }
  }

  tags = {
    Name = "${var.instance_name}-cache"
  }
}