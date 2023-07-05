resource "aws_db_subnet_group" "this" {
  name       = var.env_code
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.env_code
  }
}

resource "aws_security_group" "this" {
  name   = "${var.env_code}-rds"
  vpc_id = var.vpc_id

  ingress {
    description     = "allow db port access"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [var.source_security_group]
  }

  tags = {
    Name = var.env_code
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.env_code
  allocated_storage       = 10
  db_name                 = "mydb"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = var.rds_password
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.this.id]
  backup_retention_period = 35
  backup_window           = "20:30-22:30"
  skip_final_snapshot     = true
}
