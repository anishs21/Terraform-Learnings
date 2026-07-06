variable "name_prefix" {
  description = "Common name prefix for all resources"
  type        = string
}

variable "bucket_name_suffix" {
  description = "Unique suffix appended to the bucket name"
  type        = string
}

variable "lifecycle_transition_days" {
  description = "Days before objects transition to STANDARD_IA"
  type        = number
  default     = 30
}
