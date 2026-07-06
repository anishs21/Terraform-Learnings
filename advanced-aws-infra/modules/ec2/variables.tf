variable "name_prefix" {
  description = "Common name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the bastion will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID to place the bastion host in"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the bastion"
  type        = string
  default     = "0.0.0.0/0"
}
