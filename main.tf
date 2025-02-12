#############################
# Provider Configuration    #
#############################
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

#############################
# Network Resources         #
#############################

# VPC
resource "aws_vpc" "tolove_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.tolove_vpc.id
  cidr_block = var.subnet_cidr_a

  tags = {
    Name = var.subnet_name_a
  }
}

resource "aws_subnet" "public_subnet_b" {
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
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tolove_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.igw_name
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
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

#############################
# ECS & IAM Resources       #
#############################

# ECS Cluster
resource "aws_ecs_cluster" "events_cluster" {
  name = "tolove-events-cluster"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AWS Managed ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a custom policy to allow Secrets Manager access
resource "aws_iam_policy" "ecs_secrets_access_policy" {
  name        = "ECSSecretsAccessPolicy"
  description = "Allow ECS task execution role to retrieve Docker Hub credentials from Secrets Manager"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.aws_secretsmanager_secret.docker_hub.arn
      }
    ]
  })
}

# Attach the custom Secrets Manager policy to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_secrets_access_policy_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_secrets_access_policy.arn
}

###########################################
# Database Credentials via Secrets Data #
###########################################

# Retrieve the secret by name
data "aws_secretsmanager_secret" "postgres" {
  name = "tolove-events-db-credentials"
}

# Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "postgres_version" {
  secret_id = data.aws_secretsmanager_secret.postgres.id
}

# Decode the secret JSON (expects keys "username" and "accessToken")
locals {
  postgres_credentials = jsondecode(data.aws_secretsmanager_secret_version.postgres_version.secret_string)
}

#############################
# Database Resources        #
#############################

# (Optional) Create a dedicated security group for the database.
# You can also reuse an existing security group if that fits your security model.
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

# Create a DB Subnet Group for RDS.  
# (Typically, you'd use private subnets. Here we use the public subnet from your config for simplicity.)
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
  engine_version         = "13.4"       # adjust to your desired version
  instance_class         = "db.t3.micro" # change to suit your workload
  username               = local.postgres_credentials.db_username
  password               = local.postgres_credentials.db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true          # change to false if you want it private
  skip_final_snapshot    = true          # for testing; for production, you may not want to skip

  tags = {
    Name = "Postgres Database"
  }
}

###########################################
# Docker Hub Credentials via Secrets Data #
###########################################

# Retrieve the secret by name
data "aws_secretsmanager_secret" "docker_hub" {
  name = "docker-hub-access-events"
}

# Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "docker_hub_version" {
  secret_id = data.aws_secretsmanager_secret.docker_hub.id
}

# Decode the secret JSON (expects keys "username" and "accessToken")
locals {
  docker_hub_credentials = jsondecode(data.aws_secretsmanager_secret_version.docker_hub_version.secret_string)
}

###########################################
# Optional: CloudWatch Log Group          #
###########################################

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/server"
  retention_in_days = 7
}

###########################################
# ECS Task Definition                     #
###########################################

resource "aws_ecs_task_definition" "server_task" {
  family                   = "server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # Adjust as needed
  memory                   = "512"  # Adjust as needed
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "server",
      image = "${var.container_image_name}:${var.container_image_version}"
      command   = ["sleep", "infinity"],
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      essential = true,
      # Reference the secret for pulling the private image
      repositoryCredentials = {
        credentialsParameter = data.aws_secretsmanager_secret.docker_hub.arn
      },
      environment = [
        { name = "DATABASE_HOST", value = aws_db_instance.postgres-events.address },
        { name = "DATABASE_PORT", value = aws_db_instance.postgres-events.port },
        { name = "DATABASE_USER", value = local.postgres_credentials.db_username },
        { name = "DATABASE_PASSWORD", value = local.postgres_credentials.db_password }
      ],
      # Optional: CloudWatch Logs configuration
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region"        = "eu-north-1",
          "awslogs-stream-prefix" = "server"
        }
      }
    }
  ])
}

###########################################
# ECS Service to Run the Task             #
###########################################

resource "aws_ecs_service" "server_service" {
  name            = "server-service"
  cluster         = aws_ecs_cluster.events_cluster.id
  task_definition = aws_ecs_task_definition.server_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_a.id]
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  enable_execute_command = true
}

