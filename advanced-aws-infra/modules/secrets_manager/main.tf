# ── Secret ────────────────────────────────────────────────────────────────────
resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = "Application DB credentials managed by Terraform"
  recovery_window_in_days = var.recovery_window_days

  tags = {
    Name = var.secret_name
  }
}

# ── Initial Secret Value (placeholder — update via AWS Console or CLI) ─────────
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  # Store as JSON so applications can parse individual keys
  secret_string = jsonencode({
    username = "admin"
    password = "CHANGE_ME_BEFORE_USE"
    host     = "your-db-host.rds.amazonaws.com"
    port     = 5432
    dbname   = "appdb"
  })

  # Prevent Terraform from resetting the secret value on every plan/apply
  # once you've rotated or updated it manually
  lifecycle {
    ignore_changes = [secret_string]
  }
}
