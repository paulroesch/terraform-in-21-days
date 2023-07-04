module "vpc" {
  source = "../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  env_code            = var.env_code
}

data "aws_region" "this" {}
