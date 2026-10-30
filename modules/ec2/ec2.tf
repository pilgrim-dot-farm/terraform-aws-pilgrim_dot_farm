# The SSH key "pg" already exists in the region; reference it by name.
data "aws_key_pair" "pg" {
  key_name = var.key_name
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "pg" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.pg.key_name
  subnet_id                   = data.aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.pg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size

    tags = {
      Name = var.instance_name
    }
  }

  tags = {
    Name = var.instance_name
  }
}

# Elastic IP bound to the instance so the public address is stable.
resource "aws_eip" "pg" {
  instance = aws_instance.pg.id
  domain   = "vpc"

  tags = {
    Name = var.instance_name
  }
}
