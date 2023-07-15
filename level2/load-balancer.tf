data "aws_route53_zone" "main" {
  name = "appsite-paul.link"
}

resource "aws_route53_record" "www" {
  name    = "www.${data.aws_route53_zone.main.name}"
  zone_id = data.aws_route53_zone.main.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [module.elb.lb_dns_name]
}

resource "aws_acm_certificate" "main" {
  domain_name       = "www.appsite-paul.link"
  validation_method = "DNS"

  tags = {
    name = var.env_code
  }
}

resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "crt_validation" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}

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
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "https to ELB"
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

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.main.arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = var.env_code
  }
}
