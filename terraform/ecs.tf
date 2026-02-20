# Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "strapi-sg"
  description = "Allow Strapi access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${aws_ecr_repository.repo.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },

        { name = "APP_KEYS", value = "key1,key2,key3,key4" },
        { name = "API_TOKEN_SALT", value = "salt123" },

        { name = "ADMIN_JWT_SECRET", value = "adminsecret123" },
        { name = "JWT_SECRET", value = "jwtsecret123" },
        { name = "ADMIN_AUTH_SECRET", value = "supersecret123" },

        { name = "NODE_ENV", value = "production" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs/strapi"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_policy
  ]
}