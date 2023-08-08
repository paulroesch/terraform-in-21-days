data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name               = var.env_code
  cidr               = var.vpc_cidr
  public_subnets     = var.public_subnet_cidr
  private_subnets    = var.private_subnet_cidr
  azs                = data.aws_availability_zones.available.names[*]
  enable_nat_gateway = true

  tags = {
    Environment = var.env_code
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.env_code}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.env_code}" = "shared"
  }
}

data "aws_region" "this" {}
