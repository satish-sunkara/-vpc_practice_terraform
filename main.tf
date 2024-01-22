resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.aws_vpc_tags,
    {
        Name = local.name
    }
  )
  
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = "${local.name}-igw"
    }
  )
}

# resource "aws_internet_gateway_attachment" "igw_attach" {
#   internet_gateway_id = aws_internet_gateway.gw.id
#   vpc_id              = aws_vpc.main.id
# }

resource "aws_subnet" "public" {
  count = length(var.public-vpc-cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public-vpc-cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.name}-${local.azs[count.index]}-public"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private-vpc-cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private-vpc-cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${local.name}-${local.azs[count.index]}-private"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database-vpc-cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database-vpc-cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
        Name = "${local.name}-${local.azs[count.index]}-database"
    }
  )
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  # count = length(var.public-vpc-cidr)
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_subnet_tags,
    {
        Name = "${local.name}-ngw"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.name}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.name}-private-rt"
    }
  )
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.name}-database-rt"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public-vpc-cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index) 
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private-vpc-cidr)
  subnet_id      = element(aws_subnet.private[*].id, count.index) 
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database-vpc-cidr)
  subnet_id      = element(aws_subnet.database[*].id, count.index) 
  route_table_id = aws_route_table.database.id
}


