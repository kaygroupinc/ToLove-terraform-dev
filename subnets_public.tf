# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_a" {
    availability_zone = var.subnet_region_a
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_a_public

    tags = {
        Name = "Public Subnet A"
    }
}

resource "aws_subnet" "public_subnet_b" {
    availability_zone = var.subnet_region_b
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_b_public

    tags = {
        Name = "Public Subnet B"
    }
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}