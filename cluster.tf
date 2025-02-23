# ECS Cluster
resource "aws_ecs_cluster" "events_cluster_dev" {
  name = "tolove-events-cluster-dev"
}

###########################################
# Optional: CloudWatch Log Group          #
###########################################

resource "aws_cloudwatch_log_group" "ecs_log_group_dev" {
  name              = "/ecs/server"
  retention_in_days = 7
}

###########################################
# ECS Task Definition                     #
###########################################

resource "aws_ecs_task_definition" "server_task_dev" {
  family                   = "server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # Adjust as needed
  memory                   = "512"  # Adjust as needed
  execution_role_arn       = aws_iam_role.ecs_task_execution_dev.arn
  task_role_arn            = aws_iam_role.ecs_task_role_dev.arn

  container_definitions = jsonencode([
    {
      name  = "events-server",
      image = "${var.container_image_name}:${var.container_image_version}"
      # command   = ["sleep", "infinity"],
      # command   = ["node", "dist/server.js", "false", "false"],
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
        credentialsParameter = data.aws_secretsmanager_secret.docker_hub_dev.arn
      },
      environment = [
        { name = "SERVER_PORT", value = tostring(80) },
        { name = "DATABASE_HOST", value = aws_db_instance.postgres_events_dev.address },
        { name = "DATABASE_PORT", value = tostring(aws_db_instance.postgres_events_dev.port) },
        { name = "DATABASE_USER", value = local.postgres_credentials.db_username },
        { name = "DATABASE_PASSWORD", value = local.postgres_credentials.db_password }
      ],
      # Optional: CloudWatch Logs configuration
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group_dev.name,
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

resource "aws_ecs_service" "server_service_dev" {
  name            = "events-server-service-dev"
  cluster         = aws_ecs_cluster.events_cluster_dev.id
  task_definition = aws_ecs_task_definition.server_task_dev.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.private_sg_dev.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group_dev.arn
    container_name   = "events-server"
    container_port   = 80
  }

  enable_execute_command = true
}

