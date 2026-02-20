########################################
# ECR Repository
########################################

resource "aws_ecr_repository" "repo" {
  name                 = "strapi-ecs-ahmad-amin"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "strapi-ecs-ahmad"
  }
}

########################################
# ECS Task Definition
########################################

resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task-ahmad"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = local.ecs_task_execution_role_arn
  task_role_arn      = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/strapi-ecs-ahmad:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/strapi-ahmad"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "strapi-task-ahmad"
  }
}
