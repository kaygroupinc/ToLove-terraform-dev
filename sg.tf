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