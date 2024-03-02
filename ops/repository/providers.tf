terraform {
  required_version = ">=0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }

  backend "s3" {
    bucket  = "coachcrew-terraform-state"
    key     = "demo/ecs-web-appliction-demo"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}