# ── General ──────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used as a prefix for all resource names"
  type        = string
  default     = "adv-infra"
}

variable "environment" {
  description = "Deployment environment (dev | stg | prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "environment must be one of: dev, stg, prod."
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets (one per AZ — used by EKS nodes)"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to span (must match subnet count)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# ── EC2 Bastion ───────────────────────────────────────────────────────────────

variable "bastion_ami_id" {
  description = "AMI ID for the bastion host (Ubuntu 22.04 LTS in ap-south-1)"
  type        = string
  default     = "ami-01a00762f46d584a1"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_ssh_public_key_path" {
  description = "Local path to the SSH public key for bastion access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_allowed_cidr" {
  description = "CIDR allowed to SSH into the bastion (restrict to your IP in production)"
  type        = string
  default     = "0.0.0.0/0"
}

# ── S3 ────────────────────────────────────────────────────────────────────────

variable "s3_bucket_name_suffix" {
  description = "Unique suffix appended to the S3 bucket name (must be globally unique)"
  type        = string
  default     = "app-artifacts-001"
}

variable "s3_lifecycle_transition_days" {
  description = "Days before objects transition to STANDARD_IA storage class"
  type        = number
  default     = 30
}

# ── ECR ───────────────────────────────────────────────────────────────────────

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "app-images"
}

variable "ecr_image_retention_count" {
  description = "Maximum number of tagged images to retain in ECR"
  type        = number
  default     = 10
}

# ── Secrets Manager ───────────────────────────────────────────────────────────

variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
  default     = "advanced-infra/app-db-credentials"
}

variable "secret_recovery_window_days" {
  description = "Days before a deleted secret is permanently purged (0 = immediate)"
  type        = number
  default     = 7
}

# ── EKS ───────────────────────────────────────────────────────────────────────

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS managed node group workers"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_min_count" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_max_count" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}
