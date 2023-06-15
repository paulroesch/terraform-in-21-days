terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }

  }

  backend "s3" {
    bucket         = "terraform-remote-state-17171"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-remote-state"
  }

  required_version = ">=1.2.0"
}

provider "aws" {
  region = "us-west-2"
}
