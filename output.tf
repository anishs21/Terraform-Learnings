output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.Test-instance.public_ip
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}