resource "aws_security_group" "db_sg" {
  name        = "rds-postgres-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.tolove_vpc.id

  ingress {
    description = "Allow Postgres access from the app"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # You can restrict this further (for example, allow only from your ECS security group)
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# Security Group for the ECS Service
resource "aws_security_group" "public_sg" {
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

# Security Group for the ECS Service
resource "aws_security_group" "private_sg" {
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