terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.00"
    }

  }

  backend "s3" {
    bucket         = "terraform-remote-state-17171"
    key            = "level2.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-remote-state"
  }

  required_version = ">=1.2.0"
}

provider "aws" {
  region = "us-west-2"
}
