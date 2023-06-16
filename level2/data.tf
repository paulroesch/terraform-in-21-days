data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "terraform-remote-state-17171"
    key    = "level1.tfstate"
    region = "us-west-2"
  }
}
