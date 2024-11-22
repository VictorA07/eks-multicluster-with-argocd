locals {
  name = "argocd-cluster"
}

provider "aws" {
  region  = "eu-west-2"
  profile = "lead"
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_eks_cluster_auth" "cluster_token" {
    name       = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}


terraform {
  backend "s3" {
    bucket = "chworkspaces3"
    key = "terraform.tfstate"
    dynamodb_table = "chworkspacedb"
    region = "eu-west-2"
    encrypt = true
    profile = "lead"
  }
}