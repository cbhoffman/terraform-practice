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

provider "tls" {
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
    description      = "SSH traffic to VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_traffic"
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2_keypair"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "ec2_keypair_secret" {
  name = "custom_ec2_keypair_pem2"
}

resource "aws_secretsmanager_secret_version" "ec2_keypair_secret_value" {
  secret_id     = aws_secretsmanager_secret.ec2_keypair_secret.id
  secret_string = tls_private_key.my_key.private_key_pem
  #secret_string = aws_key_pair.ec2_keypair.public_key
}

resource "aws_main_route_table_association" "custom_rt_a" {
  vpc_id         = aws_vpc.custom_vpc.id
  route_table_id = aws_route_table.custom_route_table.id
}

resource "aws_instance" "custom_instance" {
  ami           = data.aws_ami.most_recent_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.custom_subnet.id
  key_name      = aws_key_pair.ec2_keypair.key_name
  vpc_security_group_ids = [aws_security_group.ssh_traffic.id]

  tags = {
    Name = "custom_instance"
  }
}