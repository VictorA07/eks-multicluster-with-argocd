module "vpc" {
  source = "./vpc"
  count = terraform.workspace == "network" ? 1 : 0
}
module "eks" {
  source = "./eks-server"
}