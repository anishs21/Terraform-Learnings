# ── Networking ────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (EKS nodes)"
  value       = module.networking.private_subnet_ids
}

# ── EC2 Bastion ───────────────────────────────────────────────────────────────
output "bastion_public_ip" {
  description = "Public IP of the bastion host — SSH: ubuntu@<IP>"
  value       = module.ec2.bastion_public_ip
}

output "bastion_instance_id" {
  description = "EC2 Instance ID of the bastion host"
  value       = module.ec2.bastion_instance_id
}

# ── S3 ────────────────────────────────────────────────────────────────────────
output "s3_bucket_name" {
  description = "Application S3 bucket name"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "Application S3 bucket ARN"
  value       = module.s3.bucket_arn
}

# ── ECR ───────────────────────────────────────────────────────────────────────
output "ecr_repository_url" {
  description = "ECR repository URL — use as docker push target"
  value       = module.ecr.repository_url
}

# ── Secrets Manager ───────────────────────────────────────────────────────────
output "secret_arn" {
  description = "ARN of the app credentials secret in Secrets Manager"
  value       = module.secrets_manager.secret_arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.secrets_manager.secret_name
}

# ── EKS ───────────────────────────────────────────────────────────────────────
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_issuer_url" {
  description = "EKS OIDC issuer URL (for IRSA)"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_secrets_irsa_role_arn" {
  description = "IAM role ARN for pods to access Secrets Manager via IRSA"
  value       = module.eks.secrets_irsa_role_arn
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
