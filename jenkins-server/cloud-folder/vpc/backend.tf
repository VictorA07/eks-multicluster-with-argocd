terraform {
  backend "s3" {
    bucket = "chworkspaces3"
    key = "network/terraform.tfstate"
    dynamodb_table = "chworkspacedb"
    region = "eu-west-2"
    encrypt = true
    profile = "lead"
  }
}

