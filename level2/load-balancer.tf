module "lb" {
  source = "../modules/lb"

  vpc_id           = data.terraform_remote_state.level1.outputs.vpc_id
  env_code         = var.env_code
  public_subnet_id = data.terraform_remote_state.level1.outputs.public_subnet_id
}
