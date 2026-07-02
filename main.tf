terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "flask-terraform-state-sal"
    key    = "flask-vpc/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "flask-terraform-locks"
    encrypt = true
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}