variable "name_prefix" {
  description = "Common name prefix for all resources"
  type        = string
}

variable "secret_name" {
  description = "Name/path of the Secrets Manager secret"
  type        = string
}

variable "recovery_window_days" {
  description = "Days before a deleted secret is permanently purged"
  type        = number
  default     = 7
}
