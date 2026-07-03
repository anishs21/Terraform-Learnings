output "bucket_name" {
  description = "Name of the S3 bucket created for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.tf_state.arn
}

output "bucket_region" {
  description = "Region where the S3 bucket lives"
  value       = var.aws_region
}
