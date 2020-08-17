//AWS access credential validation
provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

//Creates Prod VPC
module "prod_vpc" {
  source                  = "./prod_vpc"
}
output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

//Creates Prod VPN
module "prod_vpn" {
  source                  = "./prod_openvpn"
  public_subnet_ids       = module.prod_vpc.public_subnet_ids
  vpc_id                  = module.prod_vpc.vpc_id
  vpn_name                = "prod-openvpn"
}
output "prod_vpn_public_ip" {
  value = module.prod_vpn.public_ip
}

// Jenkins server
module "prod_jenkins_server" {
  source                  = "./prod_jenkins_server"
  name                    = "prod-jenkins-server"
  private_subnet_ids      = module.prod_vpc.private_subnet_ids
  vpc_id                  = module.prod_vpc.vpc_id
  ami_id                  = "<AMI ID>" // CIS hardened Image made as Golden AMI
}
output "prod_jenkins_server_private_ip" {
  value = module.prod_jenkins_server.private_ip
}

//Creates Windows instance
//module "application_on_windows" {
//  source                  = "./application_on_windows"
//  ami_id                  = "<AMI ID>" // CIS hardened Image made as Golden AMI
//  name                    = "application_on_windows"
//  vpc_id                  = module.prod_vpc.vpc_id
//  private_subnet_ids      = module.prod_vpc.private_subnet_ids
//}
//output "application_on_windows_private_ip" {
//  value = module.application_on_windows.private_ip
//}

// Create Linux Instance
module "application_on_linux" {
  source                  = "./application_on_linux"
  name                    = "prod-livedemo"
  instance_count          = 2
  private_subnet_ids      = module.prod_vpc.private_subnet_ids
  vpc_id                  = module.prod_vpc.vpc_id
  ami_id                  = "<AMI ID>" // CIS hardened Image made as Golden AMI
}
output "application_on_linux_private_ip" {
  value = module.application_on_linux.private_ip
}

// Creating/Configuring CloudTrail with CloudWatch
//module "cloudtrail" {
//  source = "../cloudtrail"
//}


// Using the backend created in Global
terraform {
  backend "s3" {
    bucket         = "terraform-backend-state"
    key            = "global/s3/prod_setup/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-backend-locks"
    encrypt        = true
    profile        = "default"
  }
}
