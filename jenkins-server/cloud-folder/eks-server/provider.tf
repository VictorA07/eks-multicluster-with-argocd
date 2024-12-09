locals {
  name = "eks-${terraform.workspace}"
}

provider "kubernetes" {
  host = module.eks[0].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.current.token
}

provider "aws" {
  region  = "eu-west-2"
  #profile = "lead"
}



provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.current.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.current.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.current.token
  }
}
data "aws_eks_cluster" "current" {
  name = module.eks[0].cluster_name
}

data "aws_eks_cluster_auth" "current" {
  name = local.name
}

