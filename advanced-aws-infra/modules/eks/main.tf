# ─────────────────────────────────────────────────────────────────────────────
# EKS CLUSTER IAM ROLE
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name = "${var.name_prefix}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─────────────────────────────────────────────────────────────────────────────
# EKS CLUSTER
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "this" {
  name     = "${var.name_prefix}-eks"
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true # set false after kubectl is configured if needed
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  # Enable control-plane logging to CloudWatch
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = {
    Name = "${var.name_prefix}-eks"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ─────────────────────────────────────────────────────────────────────────────
# OIDC PROVIDER (required for IRSA — IAM Roles for Service Accounts)
# ─────────────────────────────────────────────────────────────────────────────
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name = "${var.name_prefix}-eks-oidc"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# NODE GROUP IAM ROLE
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json

  tags = {
    Name = "${var.name_prefix}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ─────────────────────────────────────────────────────────────────────────────
# MANAGED NODE GROUP
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_count
    min_size     = var.node_min_count
    max_size     = var.node_max_count
  }

  update_config {
    max_unavailable = 1 # rolling updates — keep n-1 nodes running at all times
  }

  # Encrypt node EBS volumes
  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version_number
  }

  tags = {
    Name = "${var.name_prefix}-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]
}

# ── Launch Template for encrypted EBS on nodes ────────────────────────────────
resource "aws_launch_template" "eks_node" {
  name_prefix = "${var.name_prefix}-eks-node-lt-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-eks-worker"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# IRSA — IAM Role for Pods to access Secrets Manager
# ─────────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "secrets_irsa_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:secrets-sa"]
    }
  }
}

resource "aws_iam_role" "secrets_irsa" {
  name               = "${var.name_prefix}-secrets-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.secrets_irsa_assume.json

  tags = {
    Name = "${var.name_prefix}-secrets-irsa-role"
  }
}

resource "aws_iam_role_policy_attachment" "secrets_irsa_policy" {
  role       = aws_iam_role.secrets_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
