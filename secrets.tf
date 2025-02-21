# Retrieve the secret by name
data "aws_secretsmanager_secret" "postgres_dev" {
  name = "tolove-events-db-credentials"
}

# Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "postgres_version_dev" {
  secret_id = data.aws_secretsmanager_secret.postgres_dev.id
}

# Decode the secret JSON (expects keys "username" and "accessToken")
locals {
  postgres_credentials = jsondecode(data.aws_secretsmanager_secret_version.postgres_version_dev.secret_string)
}

# Retrieve the secret by name
data "aws_secretsmanager_secret" "docker_hub_dev" {
  name = "docker-hub-access-events"
}

# Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "docker_hub_version_dev" {
  secret_id = data.aws_secretsmanager_secret.docker_hub_dev.id
}

# Decode the secret JSON (expects keys "username" and "accessToken")
locals {
  docker_hub_credentials = jsondecode(data.aws_secretsmanager_secret_version.docker_hub_version_dev.secret_string)
}