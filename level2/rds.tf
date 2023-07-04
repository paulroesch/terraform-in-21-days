data "aws_secretsmanager_secret" "this" {
  name = "main/rds/password"
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

locals {
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["password"]
}

module "rds" {
  source = "../modules/rds"

  subnet_ids            = data.terraform_remote_state.level1.outputs.private_subnet_id
  env_code              = var.env_code
  vpc_id                = data.terraform_remote_state.level1.outputs.vpc_id
  rds_password          = local.rds_password
  source_security_group = module.asg.security_group_id

  depends_on = [module.asg]
}
