# have this created before hand on AWS
data "aws_eip" "Development-VPC-EIP" {
  tags = {
    Name = "Development-VPC-EIP"
  }
}

module "vpc" {
  # source = "../modules/vpc"
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name = "Production-VPC"

  cidr = var.vpc_cidr_block # 172.16.0.0/16

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["172.16.1.0/24", "172.16.2.0/24"]
  public_subnets  = ["172.16.101.0/24", "172.16.102.0/24"]


  enable_dns_hostnames = true
  enable_dns_support   = true

  //  Uncomment below line to enable ipv6
  //  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  reuse_nat_ips       = true                                              # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = data.aws_eip.Development-VPC-EIP.*.id        # <= IPs specified here as input to the module

  tags = {
  Owner       = "Your-Company"
  Environment = "prod"
  }
}
