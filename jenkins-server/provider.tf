provider "aws" {
  region  = "eu-west-2"
  profile = "lead"
}

terraform {
  backend "s3" {
    bucket = "chworkspaces3"
    key = "ekshost/tfstate"
    dynamodb_table = "chworkspacedb"
    region = "eu-west-2"
    encrypt = true
    profile = "lead"
  }
}