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







