# ── Locals ────────────────────────────────────────────────────────────────────
# All resource names derive from this prefix to guarantee consistency.
# Tags are injected automatically via the provider's default_tags block.

locals {
  # e.g. "adv-infra-dev"
  name_prefix = "${var.project_name}-${var.environment}"

  # Applied to every resource in the project
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Region      = var.aws_region
  }
}
