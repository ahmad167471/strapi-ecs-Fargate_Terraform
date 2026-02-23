########################################
# AWS Region to deploy resources
########################################
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

########################################
# AWS Account ID
########################################
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

########################################
# Strapi Database Password
########################################
variable "strapi_db_password" {
  description = "Password for Strapi database"
  type        = string
  sensitive   = true
}

########################################
# Docker Image Tag for ECS Deployment
########################################
variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

########################################
# ECR Repository URI (full URI including account and region)
########################################
variable "ecr_repo_url" {
  description = "Full ECR repository URI, e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/strapi-ecs-ahmad"
  type        = string
}