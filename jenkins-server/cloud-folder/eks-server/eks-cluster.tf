
data "terraform_remote_state" "vpc" {
  count = terraform.workspace == "argocd" || terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
  backend = "s3"
  config = {
    bucket = "chworkspaces3"
    key = "eks/terraform.tfstate"
    dynamodb_table = "chworkspacedb"
    region = "eu-west-2"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  # Only deploy in dev, prod, or stage
  count = terraform.workspace == "argocd" || terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
  cluster_name    = local.name
  cluster_version = "1.27"
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                         = data.terraform_remote_state.vpc[0].outputs.vpc_id
  subnet_ids                     = data.terraform_remote_state.vpc[0].outputs.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
      eks_managed_node_groups = {
    one = {
      name = "worker-node-1"

      instance_types = [lookup(var.instance_type, terraform.workspace, "t2.micro")]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
  tags = {
    Environment = "${terraform.workspace}"
    Terraform = "true"

  }
}