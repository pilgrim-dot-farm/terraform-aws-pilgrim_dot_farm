locals {
  pg_role_arn = aws_iam_role.pg.arn
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pg" {
  name               = "${var.instance_name}-s3-read"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_instance_profile" "pg" {
  name = "${var.instance_name}-s3-read"
  role = aws_iam_role.pg.name
}

data "aws_iam_policy_document" "s3_read" {
  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [for bucket in aws_s3_bucket.pilgrim : bucket.arn]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = [for bucket in aws_s3_bucket.pilgrim : "${bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "secrets_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "pg_s3_read" {
  name   = "pilgrim-buckets-read"
  role   = aws_iam_role.pg.id
  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_role_policy" "pg_secrets_read" {
  name   = "pilgrim-secrets-read"
  role   = aws_iam_role.pg.id
  policy = data.aws_iam_policy_document.secrets_read.json
}

resource "aws_iam_user" "mac_studio" {
  name = "mac-studio"
}

data "aws_iam_policy_document" "s3_read_write" {
  source_policy_documents = [data.aws_iam_policy_document.s3_read.json]

  statement {
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [for bucket in aws_s3_bucket.pilgrim : bucket.arn]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = [for bucket in aws_s3_bucket.pilgrim : "${bucket.arn}/*"]
  }
} 

resource "aws_iam_user_policy" "mac_studio_s3" {
  name   = "pilgrim-buckets-read-write"
  user   = aws_iam_user.mac_studio.name
  policy = data.aws_iam_policy_document.s3_read_write.json
}
