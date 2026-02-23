########################################
# ECR Repository
########################################

resource "aws_ecr_repository" "repo" {
  name                 = "strapi-ecs-ahmad"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "strapi-ecs-ahmad"
  }
}
