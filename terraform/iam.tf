########################################
# IAM Configuration
########################################

# IMPORTANT:
# The IAM role `ecs_fargate_taskRole` is already created
# and managed by the organization.
#
# Role ARN:
# arn:aws:iam::811738710312:role/ecs_fargate_taskRole
#
# It already has:
# AmazonECSTaskExecutionRolePolicy attached.
#
# So we DO NOT:
# - Create IAM roles
# - Attach policies
# - Add inline policies
#
# We will ONLY reference this role in ECS task definition.

locals {
  ecs_task_execution_role_arn = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
}
