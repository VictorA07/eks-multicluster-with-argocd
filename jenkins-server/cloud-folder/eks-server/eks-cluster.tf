
# data "terraform_remote_state" "vpc" {
#   count = terraform.workspace == "argocd" || terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
#   backend = "s3"
#   config = {
#     bucket = "chworkspaces3"
#     key = "eks/terraform.tfstate"
#     dynamodb_table = "chworkspacedb"
#     region = "eu-west-2"
#   }
# }
data "aws_subnet" "shared_private_subnets" {
  for_each = toset([
    "subnet-00b53e5b85a249cf4",
    "subnet-0ef7ae75747f682be",
    "subnet-0648f5a7ba9788a24"
  ])

  id = each.value
}

data "aws_vpc" "shared-vpc" {
  id = "vpc-020d4c4a5a3d3dc9e"
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

  vpc_id                         = data.aws_vpc.shared-vpc.id
  subnet_ids                     = [for subnet in data.aws_subnet.shared_private_subnets : subnet.id]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
      eks_managed_node_groups = {
    one = {
      name = "workernode-${local.name}"

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