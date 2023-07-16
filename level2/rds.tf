data "aws_secretsmanager_secret" "this" {
  name = "main/rds/password"
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

locals {
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["password"]
}

module "private-rds-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.env_code}-internal-rds"
  description = "Allow port 3306 inbound to RDS within VPC."
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.private-asg-sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.0.0"

  engine               = "mysql"
  engine_version       = "5.7"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  identifier           = var.env_code

  db_name  = "mydb"
  port     = "3306"
  username = "admin"
  password = local.rds_password

  manage_master_user_password = false

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.private-rds-sg.security_group_id]

  multi_az            = true
  skip_final_snapshot = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Environment = var.env_code
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = data.terraform_remote_state.level1.outputs.private_subnet_id

  # Database Deletion Protection
  deletion_protection = false
}
