# VPC
resource "aws_vpc" "tolove_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.vpc_name}-dev"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tolove_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "nat-gateway"
  }
}


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

# Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table"
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

resource "aws_subnet" "private_subnet_b" {
    availability_zone = var.subnet_region_b
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_b_private

    tags = {
        Name = "Private Subnet B"
    }
}

# Route Table Association
resource "aws_route_table_association" "private_rt_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Route Table Association
resource "aws_route_table_association" "private_rt_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}
