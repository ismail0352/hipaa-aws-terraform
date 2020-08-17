variable "vpn_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {

}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_pair" {
  default = "your-key-pair-name"
}

variable "destination_path" {
  description = "Path where the 'manage_vpn.sh' file will be placed in AWS instance"
  type        = string
  default     = "/home/ubuntu/manage_vpn.sh"
}

variable "source_path" {
  description = "Path where the 'manage_vpn.sh' file is on Terraform machine"
  type        = string
  default     = "../global/scripts"
}

variable "ssh_user" {
  description = "ssh user for making connection using provisioner"
  type        = string
  default     = "ubuntu"
}

variable "ssh_key" {
  description = "ssh key for making connection using provisioner"
  type        = string
  default     = "your-key-pair-name.pem"
}

variable "ami_id" {
  description = "Ubuntu 18 ami_id"
  default     = "ami-00622b440d92e55c0"
}
