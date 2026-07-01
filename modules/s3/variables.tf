variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "demo-s3-0fhvbhs"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
