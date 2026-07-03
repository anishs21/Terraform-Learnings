variable "aws_region" {
  description = "AWS region where the S3 bucket will be created"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Globally unique name for the Terraform state S3 bucket"
  type        = string
  default     = "state-file-store-0123dhbvhj"
}
