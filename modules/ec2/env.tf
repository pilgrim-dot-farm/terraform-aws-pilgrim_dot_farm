locals {
  app_environment = {
    REDIS_URL          = local.redis_url
    DATABASE_URL       = "postgresql://${aws_db_instance.db.username}@${aws_db_instance.db.endpoint}/${aws_db_instance.db.db_name}?sslmode=require"
    DB_PASS_SECRET_ARN = local.db_secret_arn
  }
}
