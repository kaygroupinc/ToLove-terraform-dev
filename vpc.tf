# VPC
resource "aws_vpc" "tolove_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = var.vpc_name
    }
}

# Public Subnet
resource "aws_subnet" "public_subnet_a" {
    availability_zone = var.subnet_region_a
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_a

    tags = {
        Name = var.subnet_name_a
    }
}

resource "aws_subnet" "public_subnet_b" {
    availability_zone = var.subnet_region_b
    vpc_id     = aws_vpc.tolove_vpc.id
    cidr_block = var.subnet_cidr_b

    tags = {
        Name = var.subnet_name_b
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tolove_vpc.id

  tags = {
    Name = var.igw_name
  }
}

# Route Table
resource "aws_route_table" "public_rt_a" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.igw_name}_a}"
  }
}

# Route Table
resource "aws_route_table" "public_rt_b" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.igw_name}_b}"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt_a.id
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt_b.id
}

# Security Group for the ECS Service
resource "aws_security_group" "app_sg" {
  name        = "ecs-service-sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.tolove_vpc.id

  # Ingress: Allow HTTP (port 80) traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}