locals {
  app_environment = {
    REDIS_URL          = var.cache_url
    DATABASE_URL       = "postgresql://${var.db_username}@${var.db_endpoint}/${var.db_name}?sslmode=require"
    DB_PASS_SECRET_ARN = var.db_secret_arn
    STRIPE_SECRET_ARN  = var.stripe_secret_arn
  }
}
