terraform {

  # backend "s3" {
  #   bucket         = "cbh-tf-state-practice"
  #   key            = "s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform_practice_state_lock"
  #   encrypt        = true
  #   profile        = "training"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "training"
}

module "ec2_custom_instance" {
  source             = "./modules/ec2"
  subnet_id          = aws_subnet.custom_subnet.id
  security_group_ids = [aws_security_group.ssh_traffic.id, aws_security_group.http_traffic.id, aws_security_group.https_traffic.id]
  instance_name      = "My custom instance"
  instance_username  = "custom_user"
}


variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = "us-east-1a"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "custom_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  availability_zone       = var.availability_zone
  cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "custom_subnet"
  }
}

resource "aws_route_table" "custom_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = "custom_route_table"
  }
}

resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_igw"
  }
}

resource "aws_security_group" "ssh_traffic" {
  name        = "ssh_traffic"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "SSH traffic to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_traffic"
  }
}

resource "aws_security_group" "http_traffic" {
  name        = "http_traffic"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "HTTP traffic to VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http_traffic"
  }
}

resource "aws_security_group" "https_traffic" {
  name        = "https_traffic"
  description = "Allow HTTPS traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "HTTPS traffic to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "https_traffic"
  }
}

resource "aws_main_route_table_association" "custom_rt_a" {
  vpc_id         = aws_vpc.custom_vpc.id
  route_table_id = aws_route_table.custom_route_table.id
}