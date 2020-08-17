data "terraform_remote_state" "vpc" {
  backend             = "s3"
  config = {
    bucket            = "terraform-backend-state"
    key               = var.key // "global/s3/prod/vpc/terraform.tfstate"
    region            = var.region
    profile           = "default"
  }
}
