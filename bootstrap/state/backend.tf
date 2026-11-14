terraform {
  backend "s3" {
    bucket       = "pilgrim-dot-farm-tfstate"
    region       = "us-west-2"
    key          = "bootstrap/state/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
