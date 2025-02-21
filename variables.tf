variable "container_image_name" {
  description = "Value of the name for the container image"
  type = string
  default = "kaygroup/tolove"
}

variable "container_image_version" {
  description = "Value of the version for the container image"
  type = string
  default = "1.0.6"
}

variable "custom_domain" {
  description = "The custom DNS name (e.g., api.example.com) that your front end will use"
  type        = string
  default     = "kaytolove.com"
}

