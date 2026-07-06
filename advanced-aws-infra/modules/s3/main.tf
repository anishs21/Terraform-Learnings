# ── S3 Bucket ─────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "this" {
  bucket = "${var.name_prefix}-${var.bucket_name_suffix}"

  # Prevent accidental deletion in production
  lifecycle {
    prevent_destroy = false # set to true for prod environments
  }

  tags = {
    Name = "${var.name_prefix}-${var.bucket_name_suffix}"
  }
}

# ── Versioning ────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── Server-Side Encryption (SSE-S3) ──────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ── Block All Public Access ───────────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Lifecycle Policy ──────────────────────────────────────────────────────────
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  # Versioning must be enabled before applying lifecycle rules
  depends_on = [aws_s3_bucket_versioning.this]

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    # Move current objects to cheaper storage after N days
    transition {
      days          = var.lifecycle_transition_days
      storage_class = "STANDARD_IA"
    }

    # Permanently delete non-current (old) versions after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
