# AWS region to deploy resources
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# AWS account ID
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# Strapi database password (sensitive)
variable "strapi_db_password" {
  description = "Password for Strapi database"
  type        = string
  sensitive   = true
}

# Docker image tag for ECS deployment
variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

