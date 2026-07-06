# ── ECR Repository ────────────────────────────────────────────────────────────
resource "aws_ecr_repository" "this" {
  name                 = "${var.name_prefix}-${var.repo_name}"
  image_tag_mutability = "MUTABLE" # allow re-pushing the same tag (e.g. latest)

  # Scan images for known CVEs on every push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt images at rest with AES-256
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.name_prefix}-${var.repo_name}"
  }
}

# ── Lifecycle Policy ──────────────────────────────────────────────────────────
# Keeps the most recent N tagged images; untagged images are expired after 1 day
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.image_retention_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
