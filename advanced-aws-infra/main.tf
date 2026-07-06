# ─────────────────────────────────────────────────────────────────────────────
# 1. NETWORKING — VPC, subnets, IGW, NAT Gateway, route tables
# ─────────────────────────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. EC2 — Bastion host in public subnet with SSM + SSH access
# ─────────────────────────────────────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  name_prefix         = local.name_prefix
  vpc_id              = module.networking.vpc_id
  public_subnet_id    = module.networking.public_subnet_ids[0]
  ami_id              = var.bastion_ami_id
  instance_type       = var.bastion_instance_type
  ssh_public_key_path = var.bastion_ssh_public_key_path
  allowed_ssh_cidr    = var.bastion_allowed_cidr

  depends_on = [module.networking]
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. S3 — Application artifact / asset bucket
# ─────────────────────────────────────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  name_prefix               = local.name_prefix
  bucket_name_suffix        = var.s3_bucket_name_suffix
  lifecycle_transition_days = var.s3_lifecycle_transition_days
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. ECR — Private container registry for application images
# ─────────────────────────────────────────────────────────────────────────────
module "ecr" {
  source = "./modules/ecr"

  name_prefix           = local.name_prefix
  repo_name             = var.ecr_repo_name
  image_retention_count = var.ecr_image_retention_count
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. SECRETS MANAGER — App DB credentials (placeholder value)
# ─────────────────────────────────────────────────────────────────────────────
module "secrets_manager" {
  source = "./modules/secrets_manager"

  name_prefix          = local.name_prefix
  secret_name          = var.secret_name
  recovery_window_days = var.secret_recovery_window_days
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. EKS — Managed Kubernetes cluster with node group + IRSA
# ─────────────────────────────────────────────────────────────────────────────
module "eks" {
  source = "./modules/eks"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
  cluster_version    = var.eks_cluster_version
  node_instance_type = var.eks_node_instance_type
  node_desired_count = var.eks_node_desired_count
  node_min_count     = var.eks_node_min_count
  node_max_count     = var.eks_node_max_count

  depends_on = [module.networking]
}
