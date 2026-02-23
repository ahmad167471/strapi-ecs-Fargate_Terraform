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
  vpc_id      = aws_vpc.main.id

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
# Security Group for RDS access from ECS
##################################
resource "aws_security_group" "rds_sg" {
  name        = "strapi-rds-sg"
  description = "Allow ECS tasks to access RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups          = [aws_security_group.ecs_sg.id]
    description              = "Allow ECS SG access to PostgreSQL"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-rds-sg-ahmad"
  }
}

##################################
# ECS Task Definition
##################################
resource "aws_ecs_task_definition" "task" {
  family                   = "strapi-task-ahmad"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"

  execution_role_arn = local.ecs_task_execution_role_arn
  task_role_arn      = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name      = "strapi"
    image     = "${var.ecr_repo_url}:${var.image_tag}"
    essential = true

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]

    environment = [
      { name = "DATABASE_HOST",     value = "strapi-user-ahmad.cibg8qw2kouc.us-east-1.rds.amazonaws.com" },
      { name = "DATABASE_PORT",     value = "5432" },
      { name = "DATABASE_USERNAME", value = "postgres" },                 # Your RDS master username
      { name = "DATABASE_PASSWORD", value = var.strapi_db_password },    # From GitHub secret
      { name = "NODE_ENV",          value = "production" }
    ]
  }])
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
  wait_for_steady_state = false

  network_configuration {
    subnets          = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]
    security_groups  = [
      aws_security_group.ecs_sg.id
    ]
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.task
  ]
}