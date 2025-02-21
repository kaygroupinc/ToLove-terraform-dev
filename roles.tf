###########################################
# Ploicies                                #
###########################################

resource "aws_iam_policy" "ecs_ssm_policy_dev" {
  name        = "ECSECSExecSSMPolicy-dev"
  description = "Allow ECS Exec via SSM"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the AWS Managed ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_dev" {
  role       = aws_iam_role.ecs_task_execution_dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a custom policy to allow Secrets Manager access
resource "aws_iam_policy" "ecs_secrets_access_policy_dev" {
  name        = "ECSSecretsAccessPolicy-dev"
  description = "Allow ECS task execution role to retrieve Docker Hub credentials from Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.aws_secretsmanager_secret.docker_hub_dev.arn
      }
    ]
  })
}

###########################################
# Task execution                          #
###########################################

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_dev" {
  name = "ecsTaskExecutionRole-dev"

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

# Attach the custom Secrets Manager policy to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_secrets_access_policy_attach_dev" {
  role       = aws_iam_role.ecs_task_execution_dev.name
  policy_arn = aws_iam_policy.ecs_secrets_access_policy_dev.arn
}

###########################################
# Task role                               #
###########################################

resource "aws_iam_role" "ecs_task_role_dev" {
  name = "ecsTaskRole-dev"

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

resource "aws_iam_role_policy_attachment" "ecs_ssm_policy_attach_dev" {
  role       = aws_iam_role.ecs_task_role_dev.name
  policy_arn = aws_iam_policy.ecs_ssm_policy_dev.arn
}
