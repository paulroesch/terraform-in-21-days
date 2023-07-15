module "private-asg-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.env_code}-internal-asg"
  description = "Security group for allow http traffic to ec2 ASG instances"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.external-sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1


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


module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = var.env_code

  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  health_check_grace_period = 400
  vpc_zone_identifier       = data.terraform_remote_state.level1.outputs.private_subnet_id
  target_group_arns         = module.elb.target_group_arns
  force_delete              = true

  # Launch template
  launch_template_name        = "${var.env_code}-asg"
  launch_template_description = "Launch template for t3.micro instances"
  update_default_version      = true
  launch_template_version     = "$Latest"

  image_id          = data.aws_ami.amazonlinux.id
  instance_type     = "t3.micro"
  enable_monitoring = true
  key_name          = "main"
  security_groups   = [module.private-asg-sg.security_group_id]

  user_data = filebase64("user-data.sh")

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "${var.env_code}-asg"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for accessing EC2 instances with Session Manager"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = var.env_code
  }
}
