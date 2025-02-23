terraform {
  cloud {
    organization = "df-devops"
    workspaces {
      name = "ecs-ec2"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "THT-DevOps"
      ManagedBy   = "Terraform"
    }
  }
}