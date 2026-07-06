variable "name_prefix" {
  description = "Common name prefix for all resources"
  type        = string
}

variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_retention_count" {
  description = "Maximum number of tagged images to retain"
  type        = number
  default     = 10
}
