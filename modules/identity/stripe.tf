resource "aws_secretsmanager_secret" "stripe" {
  name        = "${var.instance_name}-stripe"
  description = "Stripe credentials for ${var.instance_name}"

  tags = {
    Name = "${var.instance_name}-stripe"
  }
}

resource "aws_secretsmanager_secret_version" "stripe" {
  secret_id        = aws_secretsmanager_secret.stripe.id
  secret_string_wo = sensitive(file(var.stripe_secret_file))

  # A numeric file fingerprint updates the write-only value when the file changes.
  secret_string_wo_version = parseint(substr(filesha256(var.stripe_secret_file), 0, 12), 16)
}
