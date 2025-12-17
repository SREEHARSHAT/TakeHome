data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-hub-vpc"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => cidr
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-${each.key}"
      Tier = "public"
    }
  )
}

# Private app subnets
resource "aws_subnet" "private_app" {
  for_each = {
    for idx, cidr in var.private_app_subnet_cidrs :
    idx => cidr
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key)]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-app-${each.key}"
      Tier = "private-app"
    }
  )
}

# Private ingress subnets (for TGW)
resource "aws_subnet" "private_ingress" {
  for_each = {
    for idx, cidr in var.private_ingress_subnet_cidrs :
    idx => cidr
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key)]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-ingress-${each.key}"
      Tier = "private-ingress"
    }
  )
}

# NAT: 1 per public subnet
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private app RT
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-app-rt"
    }
  )
}

resource "aws_route" "private_app_default" {
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this["0"].id
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app.id
}

# Private ingress RT (TGW route handled in TGW module)
resource "aws_route_table" "private_ingress" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-ingress-rt"
    }
  )
}

resource "aws_route_table_association" "private_ingress" {
  for_each = aws_subnet.private_ingress

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_ingress.id
}
