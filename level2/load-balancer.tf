module "external-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.env_code}-external"
  description = "Security group for allow http traffic to ELB and egress traffic to targets"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http to ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "all ports to target"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "elb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7"

  name            = var.env_code
  vpc_id          = data.terraform_remote_state.level1.outputs.vpc_id
  internal        = false
  subnets         = data.terraform_remote_state.level1.outputs.public_subnet_id
  security_groups = [module.external-sg.security_group_id]

  enable_deletion_protection = false

  target_groups = [
    {
      name_prefix      = var.env_code
      backend_protocol = "HTTP"
      backend_port     = 80

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.env_code
  }
}
