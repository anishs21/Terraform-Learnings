output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.Test-instance.public_ip
}