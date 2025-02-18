resource "aws_eip" "nat_eip_a" {
  tags = {
    Name = "nat-eip-a"
  }
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "nat-gateway-a"
  }
}

# Route Table
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_a.id
  }

  tags = {
    Name = "Private Route Table A"
  }
}

# Public Subnet
resource "aws_subnet" "private_subnet_a" {
    availability_zone = var.subnet_region_a
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_a_private

    tags = {
        Name = "Private Subnet A"
    }
}

# Route Table Association
resource "aws_route_table_association" "private_rt_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}


resource "aws_eip" "nat_eip_b" {
  tags = {
    Name = "nat-eip-b"
  }
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "nat-gateway-b"
  }
}

# Route Table
resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_b.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_subnet" "private_subnet_b" {
    availability_zone = var.subnet_region_b
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_b_private

    tags = {
        Name = "Private Subnet B"
    }
}


# Route Table Association
resource "aws_route_table_association" "private_rt_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}