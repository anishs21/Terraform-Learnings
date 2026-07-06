terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Automatically applies common tags to every resource in the project
  default_tags {
    tags = local.common_tags
  }
}
