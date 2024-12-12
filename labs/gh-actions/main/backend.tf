terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-skearney00"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
} 