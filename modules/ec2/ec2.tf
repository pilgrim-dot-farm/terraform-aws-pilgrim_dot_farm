# The SSH key "pg" already exists in the region; reference it by name.
data "aws_key_pair" "pg" {
  key_name = var.key_name
}

resource "aws_instance" "pg" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.pg.key_name
  subnet_id                   = data.aws_subnet.public[0].id
  vpc_security_group_ids      = local.front_end_sg_ids
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.pg.name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size

    tags = {
      Name = var.instance_name
    }
  }

  tags = merge(local.app_environment, {
    Name = var.instance_name
  })
}

# Elastic IP bound to the instance so the public address is stable.
resource "aws_eip" "pg" {
  instance = aws_instance.pg.id
  domain   = "vpc"

  tags = {
    Name = var.instance_name
  }
}
