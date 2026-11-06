locals {
  db_secret_arn = aws_db_instance.db.master_user_secret[0].secret_arn
}

resource "aws_db_subnet_group" "db_private" {
  name       = "${var.instance_name}-db-private"
  subnet_ids = local.private_subnet_ids

  tags = {
    Name = "${var.instance_name}-db-private"
  }
}

resource "aws_db_instance" "db" {
  identifier     = "${var.instance_name}-db"
  engine         = "postgres"
  engine_version = "18.6"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name                      = "pilgrim"
  username                     = "pilgrim"
  manage_master_user_password  = true
  port                         = var.db_port
  db_subnet_group_name         = aws_db_subnet_group.db_private.name
  vpc_security_group_ids       = [aws_security_group.db.id]
  publicly_accessible          = false
  multi_az                     = false
  auto_minor_version_upgrade   = true
  backup_retention_period      = 1
  skip_final_snapshot          = false
  final_snapshot_identifier    = "${var.instance_name}-db-final"
  copy_tags_to_snapshot        = true
  monitoring_interval          = 0
  performance_insights_enabled = false

  tags = {
    Name = "${var.instance_name}-db"
  }
}
