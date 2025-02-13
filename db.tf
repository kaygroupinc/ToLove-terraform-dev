resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "Postgres Subnet Group"
  }
}

# Create the RDS PostgreSQL instance.
resource "aws_db_instance" "postgres-events" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  username               = local.postgres_credentials.db_username
  password               = local.postgres_credentials.db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = false  # Ensure a final snapshot is taken
  final_snapshot_identifier = "final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name = "Postgres Database"
  }
}