
provider "aws" {
  region  = "eu-west-2"
  #profile = "lead"

}
variable "clusters-name" {
  type    = list(string)
  default = ["eks-argocd", "eks-dev", "eks-prod"] 
}
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "cluster-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = merge(
    { "kubernetes.io/role/elb" = 1 }, # Static tag
    { for cluster in var.clusters-name :
      "kubernetes.io/cluster/${cluster}" => "shared" # Dynamic tags for each cluster
    }
  )

  private_subnet_tags = merge(
    { "kubernetes.io/role/internal-elb" = 1 }, # Static tag
    { for cluster in var.clusters-name :
      "kubernetes.io/cluster/${cluster}" => "shared" # Dynamic tags for each cluster
    }
  )

}