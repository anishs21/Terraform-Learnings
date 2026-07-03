terraform {
  backend "s3" {
    bucket       = "state-file-store-0123dhbvhj" # same bucket from bootstrap
    key          = "main/terraform.tfstate"      # path inside the bucket
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # native S3 locking (no DynamoDB needed, AWS provider ≥ 5.x)
  }
}
