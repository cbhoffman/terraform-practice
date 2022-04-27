terraform {

  backend "s3" {
    bucket = "cbh-tf-state-practice"
    key    = "s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_practice_state_lock"
    encrypt = true
    profile = "training"
  }

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