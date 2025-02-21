resource "aws_security_group" "db_sg_dev" {
  name        = "rds-postgres-sg-dev"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = module.vpc.vpc_id

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
    Name = "rds-postgres-sg-dev"
  }
}

# Security Group for the ECS Service
resource "aws_security_group" "public_sg_dev" {
  name        = "public-sg-dev"
  description = "Allow inbound HTTP traffic"
  vpc_id      = module.vpc.vpc_id

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
resource "aws_security_group" "private_sg_dev" {
  name        = "private-sg-dev"
  description = "Allow inbound HTTP traffic"
  vpc_id      = module.vpc.vpc_id

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