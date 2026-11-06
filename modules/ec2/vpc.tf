locals {
  private_subnet_ids   = aws_subnet.private.*.id
  private_subnet_cidrs = [for val in [48, 64]: "172.31.${val}.0/20"]
}
data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnets in the default VPC (those that auto-assign public IPs).
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_subnet" "public" {
  count = length(data.aws_subnets.public.ids)
  id    = data.aws_subnets.public.ids[count.index]
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id     = data.aws_vpc.default.id
  cidr_block = local.private_subnet_cidrs[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-${count.index}"
  }
}