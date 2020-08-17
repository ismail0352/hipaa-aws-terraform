module "prod-openvpn-sg" {
  # source                    = "../modules/security-group"
  source                    = "github.com/terraform-aws-modules/terraform-aws-security-group"
  name                      = "${var.vpn_name}-sg"
  description               = "Security Group for openvpn server Prod"
  vpc_id                    = var.vpc_id
  ingress_cidr_blocks       = ["0.0.0.0/0"] # Actual IP range to support
  ingress_ipv6_cidr_blocks  = ["::/0"]
  ingress_rules             = ["openvpn-udp", "openvpn-tcp", "openvpn-https-tcp", "ssh-tcp"]
  egress_rules              = ["all-all"]

  tags = {
    Owner              = "Your Company"
  }
}

data "aws_ami" "ubuntu18" {
  most_recent = true
  owners = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] # Use your already hardened ami here.
  }
}

data "template_file" "openvpn" {
  template = file("${path.module}/${var.source_path}/create-vpn.sh")
  vars = {
    client = "Company-prod"
  }
}

module "ec2" {
//  source = "../modules/ec2-instance"
  source                      = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"
  instance_count              = 1
  name                        = "${var.vpn_name}-server"
  ami                         = data.aws_ami.ubuntu18.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [module.prod-openvpn-sg.this_security_group_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.openvpn.rendered
  key_name                    = var.key_pair

  tags = {
    Owner = "Your Company"
  }
}

resource "null_resource" "prod-vpnserver" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("../${var.key_pair}.pem")
    host        = element(module.ec2.public_ip, 0 )
  }

  provisioner "file" {
    source      = "${path.module}/${var.source_path}/manage_vpn.sh"
    destination = var.destination_path
    //    on_failure  = "continue"
  }

  //  To change permission
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.destination_path}",
    ]
  }
}
