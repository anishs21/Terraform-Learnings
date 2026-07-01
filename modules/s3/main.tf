resource "aws_s3_bucket" "demo-s3-0fhvbhs" {
  bucket = var.bucket_name

  tags = var.tags
}