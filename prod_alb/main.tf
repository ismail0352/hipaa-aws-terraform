module "alb_security_group" {
//  source  = "../modules/security-group"
  source = "github.com/terraform-aws-modules/terraform-aws-security-group"

  name        = "alb-sg"
  description = "Security group for Prod ALB"
  vpc_id      = module.backend_terraform_state.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

##################################################################
# Application Load Balancer
##################################################################
module "alb" {
//  source = "../modules/alb"
  source = "github.com/terraform-aws-modules/terraform-aws-alb"
  name = "prod-alb"

  load_balancer_type = "application"

  vpc_id          = module.backend_terraform_state.vpc_id
  security_groups = [module.alb_security_group.this_security_group_id]
  subnets         = module.backend_terraform_state.public_subnet_ids

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  //  https_listeners = [
  //    {
  //      port               = 443
  //      protocol           = "HTTPS"
  //      certificate_arn    = data.aws_acm_certificate.your-company.arn
  //      target_group_index = 1
  //    },
  //  ]

  target_groups = [
    {
      name                 = "target-group-prod-alb"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        //        port                = "traffic-port"
        port                = 8080
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

  tags = {
    Owner = "your-company"
    Environment = "Prod"
  }
}
