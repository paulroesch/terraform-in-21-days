terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>4.16"
        }
        
    }

    required_version = ">=1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "name" {
  ami = "ami-0715c1897453cabd1"
  instance_type = "t2.micro"
}
