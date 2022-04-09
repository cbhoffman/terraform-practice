terraform {
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

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = "us-east-1a"
}

data "aws_ami" "most_recent_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "custom_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = var.availability_zone
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)

  tags = {
    Name = "custom_subnet"
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.most_recent_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.custom_subnet.id

  tags = {
    Name = "terraform-example"
  }
}