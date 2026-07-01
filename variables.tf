variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Define an input variable for the EC2 instance AMI ID
variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "ami_id_1" {
  description = "EC2 AMI ID for Test-instance-2"
  type        = string
}

variable "instance_type_1" {
  description = "EC2 instance type for Test-instance-2"
  type        = string
}