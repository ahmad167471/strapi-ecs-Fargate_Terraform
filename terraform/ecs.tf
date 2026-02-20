##################################
# ECS Cluster
##################################
resource "aws_ecs_cluster" "cluster" {
  name = "strapi-cluster-ahmad"
}

##################################
# Security Group for ECS
##################################
resource "aws_security_group" "ecs_sg" {
  name        = "strapi-ecs-sg"
  description = "Allow HTTP for Strapi"
  vpc_id      = aws_vpc.main.id  # updated to match new VPC

  ingress {
    description = "Strapi Port"
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

  tags = {
    Name = "strapi-ecs-sg-ahmad"
  }
}

##################################
# CloudWatch Logs
##################################
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/strapi/ahmad"
  retention_in_days = 7
}

##################################
# ECS Task Definition
##################################
#Fixed errors
resource "aws_ecs_task_definition" "task" {
  family                   = "strapi-task-ahmad"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"

  execution_role_arn = local.ecs_task_execution_role_arn
  task_role_arn      = local.ecs_task_execution_role_arn

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
        { name = "NODE_ENV", value = "production" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

##################################
# ECS Service
##################################
resource "aws_ecs_service" "service" {
  name            = "strapi-service-ahmad"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_logs
  ]
}
