terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  alias  = "region-1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "region-2"
  region = "us-east-1"
}
