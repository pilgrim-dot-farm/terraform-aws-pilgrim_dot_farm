locals {
  private_subnet_ids   = aws_subnet.private.*.id
  private_subnet_cidrs = [for val in [48, 64] : "172.31.${val}.0/20"]
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

# Share one public NAT gateway across the private subnets. The default VPC's
# public subnets already route internet traffic through its internet gateway.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.instance_name}-nat"
  }
}

resource "aws_nat_gateway" "private_egress" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = sort(data.aws_subnets.public.ids)[0]
  connectivity_type = "public"

  tags = {
    Name = "${var.instance_name}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_egress.id
  }

  tags = {
    Name = "${var.instance_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(local.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
