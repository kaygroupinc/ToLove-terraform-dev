# output "instance_id" {
#     description = "ID of EC2 instance"
#     value = aws_instance.server.id
# }

# output "instance_public_ip" {
#     description = "public IP address of the EC2 instance"
#     value = aws_instance.server.public_ip
# }

output "dockerhub_username" {
  value       = local.docker_hub_credentials.username
  description = "The Docker Hub username from the secret"
  sensitive   = true
}

output "dockerhub_access_token" {
  value       = local.docker_hub_credentials.password
  description = "The Docker Hub access token from the secret"
  sensitive   = true
}