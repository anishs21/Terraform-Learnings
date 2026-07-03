##############################################################
# BOOTSTRAP — Phase 1
# Run this ONCE to create the S3 bucket for remote state.
# This uses LOCAL state intentionally (no backend block).
##############################################################

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
}

# ─────────────────────────────────────────────
# S3 Bucket — stores Terraform state files
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.bucket_name
  force_destroy = false # Safety: set true only if you want to delete even with state inside

  tags = {
    Name        = "Terraform State Bucket"
    ManagedBy   = "Terraform Bootstrap"
    Environment = "shared"
  }
}

# Enable versioning — lets you recover old state files
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access — state files must NEVER be public
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
