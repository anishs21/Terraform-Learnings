terraform {
  backend "s3" {
    bucket       = "state-file-store-0123dhbvhj" # reuse existing bootstrap bucket
    key          = "advanced/terraform.tfstate"  # isolated key — no conflict with main state
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # native S3 locking (no DynamoDB needed)
  }
}
