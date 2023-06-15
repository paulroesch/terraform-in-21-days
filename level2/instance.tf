data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow public traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["184.170.242.170/32"]
  }

  ingress {
    description = "http traffic from home"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["184.170.242.170/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [data.terraform_remote_state.level1.outputs.aws_security_group.public[0]]
  key_name                    = "main"
  associate_public_ip_address = true
  user_data                   = file("user-data.sh")

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow private traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-private"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[0]
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = "main"

  tags = {
    Name = "${var.env_code}-private"
  }
}


output "public_ip_address" {
  value = aws_instance.public[*].public_ip
}

output "private_ip_address" {
  value = aws_instance.private[*].private_ip
}