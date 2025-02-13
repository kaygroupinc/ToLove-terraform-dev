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