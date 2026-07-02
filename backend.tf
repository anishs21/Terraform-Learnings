terraform {
  backend "s3" {
    bucket       = "state-file-store-0123dhbvhj"
    key          = "tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
