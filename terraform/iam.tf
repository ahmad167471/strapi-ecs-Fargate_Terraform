########################################
# IAM Role for ECS Task (Existing)
########################################

# No need to create a new role since your org provides ecs_fargate_taskRole
# We just reference it in ECS task definitions

# Optional: Attach policy if needed (skip if already attached)
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = "ecs_fargate_taskRole"  # Existing role name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################################
# IAM Role for ECS Task to access other AWS resources (if needed)
########################################

# Example: If your ECS tasks need to access S3, DynamoDB, etc., you can create a custom policy
resource "aws_iam_role_policy" "ecs_task_custom_policy" {
  name   = "ecs-task-custom-policy-strapi"
  role   = "ecs_fargate_taskRole"  # Existing role
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::your-bucket-name/*"
      }
    ]
  })
}
