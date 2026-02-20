terraform {
  backend "s3" {
    bucket = "ahmad-tf-state-bucket"
    key    = "strapi/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

##################################
# VPC
##################################
resource "aws_vpc" "strapi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "strapi-vpc"
  }
}

##################################
# Internet Gateway
##################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.strapi_vpc.id
  tags = {
    Name = "strapi-igw"
  }
}

##################################
# Public Subnets
##################################
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "strapi-public-a" }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "strapi-public-b" }
}

##################################
# Route Table
##################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.strapi_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "strapi-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

##################################
# ECS Cluster
##################################
resource "aws_ecs_cluster" "cluster" {
  name = "strapi-cluster-ahmad"
}

##################################
# Data sources for ECS networking
##################################
data "aws_subnets" "public_subnets" {
  ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}
